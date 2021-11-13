- [Use case of this Github](use-case-of-this-github )

# Prerequisites

- [Azure Subscription](https://azure.microsoft.com/free)
- [Azure Storage Account or Emulator](https://docs.microsoft.com/azure/logic-apps/create-stateful-stateless-workflows-visual-studio-code#storage-requirements)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Logic App Tools List](https://docs.microsoft.com/azure/logic-apps/create-stateful-stateless-workflows-visual-studio-code#tools)

# Use case of this Github 

The use case of this Github is to illustrate two design patterns (integration) to copy large file in Azure.  This scenario is to copy one large file from an Azure Storage Container to another Azure Storage Container.

The first solution is the code less optimum approach, this leverage Azure Logic App and Azure Data Factory.

The second option is the **hard way**, leveraging Azure Durable Function.  Even if the second option works a without problem you will see the first option is easier to maintain because mostly no codes need to be done.

# Architecture diagram

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/architecture.png)

The logic app here can call the two different workflows.

1) Logic App call the Data Factory that will copy the specific file.

2) Logic App call the durable function that will leverage the C# SDK of Azure.Blob.Storage to do an asynchronous copy.

3) Once completed the durable function write a message in the Azure Storage Queue.

Keep in mind, you don't need a logic app to start those two flows.  You could listen to file upload of the source storage using Event Grid is you use the Durable function.

For DataFactory, it is possible to listen to [events](https://docs.microsoft.com/en-us/azure/data-factory/how-to-create-event-trigger?tabs=data-factory) to, the logic app in a workflow here is optional depending of your business logic.

# Run this Github repository

## Step 1 - Fork the GitHub Repository

Click the button in the top right corner to Fork the git repository.

![function](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/fork.png)

## Step 2 - Create a Service Principal for the GitHub Action

The creation of all the Azure resources and deployment of all applications is done in this sample using a GitHub Action.  You will need to create a service principal that will be used to deploy everything.

To achieve this, please follow this [link](https://github.com/marketplace/actions/azure-login).  Be sure to save the output generated by the command line.  You will need it after to create a **GitHub Secret**.

The output will look like below.  Copy it in your clipboard.

![sp](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/spoutput.png)

## Step 3 - Create needed GitHub Secrets

For the GitHub Action to run properly you need to create 3 secrets.

First go to the Settings tab.

![settings](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/settings.png)

Next click the **Secrets** button in the left menu.

![leftmenu](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/leftmenu.png)

You will need to create two secrets.

| Secret Name | Description 
|-------------|------------
| SUBSCRIPTION_ID | The ID of your Azure Subscription
| AZURE_CREDENTIAL | This is the value returned when creating the Service Principal from the previous step

## Step 4 - Run the Github Action

Now it is time to deploy and create all resources in Azure.  To do this, go to the GitHub Action tab.

![action](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/actionmenu.png)

Because you **forked** this repo, you won't see by default the GitHub action, you will need to enable it.

![action](https://raw.githubusercontent.com/hugogirard/durableFunctionFormRecognizer/main/images/enablegh.png)

Once the GitHub Action is enabled, you will see on action in the left menu called **Deploy**.  You can click on it and click the Run workflow button.

This will create all the Azure resources, the Azure DataFactory pipeline and deploying the Azure Function.

## Step 5 - Add one appsettings in the Logic App

Now, you need to go to the resource group in Azure called **rg-logic-app-pattern**.  You will see an Azure function called **processor**, click on it.

Click on the left menu on the **Functions** button, here you will see multiple functions, click on the one called **ProcessorTrigger**.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/startcopyfunction.png)

Now in the top menu, click on the button **Get Function Url**.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/functionUrl.png)

Copy the URL of the function.

Now, go to the logic app deployed in the resource group, click on the **Configuration** button in the left menu.

Click on the button **New application setting** at the top.

From there you need to enter a new value

| Name | Value
|------|-------
| function_url | The value copied from the function URL

Now click save.

## Step 6 - Deploy the Logic App

You will now need to deploy Logic App using Visual Studio Code.  Now navigate where you cloned the github repository.

You will find a folder inside it called src/logicApp, open this folder with **Visual Studio Code**.

You will see a folder called **StartCopyFile**, expand it and you will see a file called **workflow.json**.

Right click on it and select the option **Open in Designer**.

You will need to add one new action, in the false condition click on the **+ button** to add one action.

Select the menu **Azure** NOT the Built-in.  In the search connector field enter **data factory**.  Select the **Create a pipeline run**.

Field the form with the value created in the resource group and don't forget to enter the parameter.  At the end it should look like this.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/createpipelinerun.png).

**IMPORTANT**, click the save button in the top menu of the designer.

Now, enter the command palet of Visual Studio Code, from there enter **Azure Logic Apps deploy to Logic App**.  You can now deploy the logic app in the resource group created with the Github Action.

## Step 7 - Copy a file to the source storage

Now, if you go to the resource group, you will see **4 Azure storage**.

Click on the one with the tag Description: **Document Source Storage**.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/str.png).

You will see a container called **documents**, one a large file there.  If you don't have a large file you can go to the folder **src/console** on this Github.

You will find a dotnet console that can generate large file.

By default this program generate a 1GB file but you can change the **const variable** to create larger file.

Upload the large file in the storage.

## Step 8 - Run the Logic App

Now, go to the logic app created in the resource group, click on the left menu on the **Workflows** button.  You will see one workflow called **StartCopyFile**, click on it.

Copy the workflow URL.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/wrkurl.png).

Now you need to do a POST call, you can use a tool like Postman.

In this example we use postman, the call will look like this.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/postman.png).

What is important here are the two parameters in the body.

| Parameter | Description
| --------- | -----------
| filename  | The name of the file copied in the Azure Storage
| operation | Here the value can be function or factory

For the operation the function value will call the azure function and factory will call Azure Data Factory.

**For now, the logic doesn't take care of the extension of the file, the copied file will always have the .txt extension**

You can POST the request, if everything is setup correctly you should receive a 202 Accepted code

## Validate the run in Azure Data Factory

Now, go to the Azure Portal, and click the Azure Data Factory, click the button **Open Azure Data Factory Studio**. Click on the left menu the button Monitor and you should see you execution succesfully.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/facrun.png).

You can now goes to the Azure Storage wit the tag **description: Document Destination Storage** and you will see in the container folder your new document.

## Call the durable function

Repeat the step 8 but for the **operation** parameter use the value **function**.

Now to validate the Azure Function was called and completed succesfully go to the processor function in the resource group.

From there click functions and select the **ProcessorTrigger**, click monitoring and you will see all execution of the Azure Function.

![architecture](https://raw.githubusercontent.com/hugogirard/logicAppPattern/main/pictures/runfunction.png).
