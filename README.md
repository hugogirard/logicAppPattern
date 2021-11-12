- [Use case of this Github](use-case-of-this-github )

# Use case of this Github 

The use case of this Github is to illustrate two design patterns (integration) to copy large file in Azure.  This scenario is to copy one large file from an Azure Storage Container to another Azure Storage Container.

The first solution is the code less optimum approach, this leverage Azure Logic App and Azure Data Factory.

The second option is the **hard way**, leveraging Azure Durable Function.  Even if the second option works a without problem you will see the first option is easier to maintain because mostly no codes need to be done.

# Architecture diagram

[architecture]()