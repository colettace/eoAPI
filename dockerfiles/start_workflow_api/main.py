from fastapi import FastAPI
import nbformat

app = FastAPI(
    title = "3DEP Data Ecosystem \"Start Workflow\" API"
    description = "After the user fills up their cart with their selected data products, they will click the \"Start Workflow\" button. That button will make a POST request aginst this API, passing the STAC items associated with their selected data products (that are \"in their cart\") as well as a string indicating the desired 3DEP workflow. This microservice then will perform a file copy of the Jupyter notebook template that is associated with the desired 3DEP workflow, and programmatically insert a cell at the top of the jupyter notebook containing the STAC data payload.",
    version = "0.2"
)

@app.get("/")
def StartWorkflow( workflow: str, stac_items: str ):
    # Step 1
    # copy OpenTopo jupyter notebook from docker mounted volume 
    # OT_3DEP_Workflows to an appropriate location for the user
    # Step 2
    # Use nbformat.read to read in the copied file. 
    # Use nbformat.v4.new_markdown_cell to create a new cell
    # Use nbformat.write to write the notebook back out
    # Step 3
    # return an HTTP redirect tnbformat.writeo the client to open up the new file
    return {
        "workflow": workflow,
        "stac_items": stac_items
    }

