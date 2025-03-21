# -----------------------------------------------------------------------------
# Dockerfile for dock-tools
# Maintainers:  
#   - Carlos Fernandez-Lozano <carlos.fernandez@udc.es>  
#   - Francisco Cedrón Santaeufemia <francisco.cedron@udc.es> 
#   - Diego Fernandez-Edreira <diego.fedreira@udc.es> 
# Version: 1.0
# Description: Lightweight base image designed to support the deployment of 
#              molecular docking tools. Includes essential dependencies and 
#              optimized configurations for computational chemistry and 
#              bioinformatics workflows.
# -----------------------------------------------------------------------------

FROM mambaorg/micromamba:2.0.5

WORKDIR /home/mambauser
COPY env.yml .

RUN micromamba install --yes --name base -f env.yml \
    && micromamba clean --all --yes

ARG MAMBA_DOCKERFILE_ACTIVATE=1

USER root
ENV workspace /app
WORKDIR $workspace
COPY source/ .
RUN chmod +x start.sh
RUN mkdir /input 
RUN mkdir /output

ENTRYPOINT ["/app/start.sh"]