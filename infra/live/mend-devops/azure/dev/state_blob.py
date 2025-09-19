import azure.identity
import azure.mgmt.resource
import azure.mgmt.storage
import azure.storage.blob
from typing import Optional


class StateBlob:
    def __init__(self, project: str, environment: str, owner: str, region: str, 
                 tenant_id: str, subscription_id: str, profile: Optional[str] = None):
        self.tenant_id = tenant_id
        self.subscription_id = subscription_id
        self.region = region
        
        # Initialize Azure credentials and clients
        self.credential = self.get_credential()
        self.resource_client = azure.mgmt.resource.ResourceManagementClient(
            self.credential, subscription_id
        )
        self.storage_client = azure.mgmt.storage.StorageManagementClient(
            self.credential, subscription_id
        )
        
        self.tags = {
            "Project": project,
            "Environment": environment,
            "Owner": owner,
            "Region": region
        }
        
        print(f"Logged in to Azure Subscription: {self.subscription_id} in Region: {self.region}")

    def get_credential(self) -> azure.identity.DefaultAzureCredential:
        """Get Azure credentials using DefaultAzureCredential"""
        try:
            return azure.identity.DefaultAzureCredential()
        except Exception as e:
            print(f"Error getting Azure credentials: {e}")
            raise

    def ensure_resource_group(self, resource_group_name: str) -> None:
        """Create Azure Resource Group if missing.
        
        Idempotent: safe to call multiple times.
        """
        try:
            # Check if resource group exists
            self.resource_client.resource_groups.get(resource_group_name)
            print(f"Resource group '{resource_group_name}' already exists")
        except azure.core.exceptions.ResourceNotFoundError:
            # Create resource group if it doesn't exist
            print(f"Creating resource group '{resource_group_name}'")
            self.resource_client.resource_groups.create_or_update(
                resource_group_name,
                {
                    "location": self.region,
                    "tags": self.tags
                }
            )
            print(f"Resource group '{resource_group_name}' created successfully")

    def ensure_storage_account(self, resource_group_name: str, storage_account_name: str) -> None:
        """Create Azure Storage Account if missing with proper configuration.
        
        Idempotent: safe to call multiple times.
        """
        try:
            # Check if storage account exists
            storage_account = self.storage_client.storage_accounts.get_properties(
                resource_group_name, storage_account_name
            )
            print(f"Storage account '{storage_account_name}' already exists")
        except azure.core.exceptions.ResourceNotFoundError:
            # Create storage account if it doesn't exist
            print(f"Creating storage account '{storage_account_name}'")
            
            # Storage account creation parameters
            storage_account_params = {
                "location": self.region,
                "sku": {
                    "name": "Standard_LRS"  # Locally redundant storage
                },
                "kind": "StorageV2",
                "access_tier": "Hot",
                "enable_https_traffic_only": True,
                "minimum_tls_version": "TLS1_2",
                "allow_blob_public_access": False,  # Block public access
                "tags": self.tags
            }
            
            # Create the storage account
            poller = self.storage_client.storage_accounts.begin_create(
                resource_group_name, storage_account_name, storage_account_params
            )
            storage_account = poller.result()
            print(f"Storage account '{storage_account_name}' created successfully")

    def ensure_blob_container(self, resource_group_name: str, storage_account_name: str, container_name: str) -> None:
        """Create blob container for Terraform state if missing.
        
        Idempotent: safe to call multiple times.
        """
        
        try:
            # Get storage account keys
            keys = self.storage_client.storage_accounts.list_keys(
                resource_group_name, storage_account_name
            )
            storage_key = keys.keys[0].value
            
            # Create blob service client
            blob_service_client = azure.storage.blob.BlobServiceClient(
                account_url=f"https://{storage_account_name}.blob.core.windows.net",
                credential=storage_key
            )
            
            # Check if container exists
            container_client = blob_service_client.get_container_client(container_name)
            
            if not container_client.exists():
                # Create container if it doesn't exist
                print(f"Creating blob container '{container_name}'")
                blob_service_client.create_container(
                    container_name,
                    metadata=self.tags
                )
                print(f"Blob container '{container_name}' created successfully")
            else:
                print(f"Blob container '{container_name}' already exists")
                
        except Exception as e:
            print(f"Error creating blob container: {e}")
            raise


def main() -> None:
    owner = "stavco9@gmail.com"
    region = "West Europe"
    region_short = ''.join([x[0] for x in region.lower().split(' ')])
    subscription_id = "2bcfe589-26cd-455a-bdd4-b8975088c52f"
    tenant_id = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
    tenant_short = tenant_id.split('-')[0]
    project = "mend-devops"
    environment = "dev"
    container_name = "terraform-state"


    state_blob = StateBlob(project, environment, owner, region, tenant_id, subscription_id)
    
    resource_group_name = f"{project}-{environment}-{region.lower().replace(' ', '-')}-rg"
    
    # Storage account name must be 24 characters or less, and it must be unique in all of Azure
    storage_account_name = f"{project.replace('-', '')}{environment}{region_short}{tenant_short}"[:24]
    
    # Ensure resource group exists
    state_blob.ensure_resource_group(resource_group_name)
    
    # Ensure storage account and blob container exist
    state_blob.ensure_storage_account(resource_group_name, storage_account_name)

    # Ensure blob container exists
    state_blob.ensure_blob_container(resource_group_name, storage_account_name, container_name)
    
    print(
        f"Ensured Resource Group '{resource_group_name}' and Storage Account '{storage_account_name}' "
        f"with blob container in region '{state_blob.region}'."
    )


if __name__ == "__main__":
    main()
