# Psorcast Validation Manuscript
Github Repository for Rerunning Psorcast In-Clinic Validation Manuscript


## Description
This github repository will help you parse through every step of analysis for Psorcast In-Clinic Validation Manuscript using `make` to streamline the process. 

## Running in Docker (Recommended):
Docker image is designed to build R & Python Environment and deployed in a container. Environment in R uses `renv` and Python `virtualenv` package management.  

### 1. Clone the repository: 
```zsh
git clone https://github.com/Sage-Bionetworks/psorcast-validation-manuscript.git
```
### 2. Build Image:
```zsh
docker build -t 'psorcast-manuscript' .
```
### 3. Run Image as Container:
```zsh
docker run -itd psorcast-manuscript
```
Notes: Argument -itd is used to make sure that container is run in detached mode (not removed after running once)

### 4. Execute Container:
#### Check Container ID:
```zsh
docker ps -a
```
Using this command, it will output container that contains the saved image. Fetch the container ID to proceed.

#### Fetch container ID and create Synapse Authentication:
```zsh
docker exec -it <CONTAINER_ID> make authenticate PARAMS="-u <username> -p <password> -g <git_token>"
```


#### Use same container ID and use Makefile to rerun workflow:
```zsh
docker exec -it <CONTAINER_ID> make rerun
```

## Contributing Docs:
Guidelines to contribute to this Github Repository will be documented in [`/docs`](https://github.com/Sage-Bionetworks/psorcast-validation-manuscript/tree/main/docs)
