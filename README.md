# Create and Update Resources

Go to src directory which contains the terraform templates.

1. Create a Plan

    ```bash
    terraform plan -out=tfplan.zip
    ```

2. Apply the plan

    ```bash
    terraform apply "tfplan.zip"
    ```
