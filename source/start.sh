#!/bin/bash

usage() {
  echo 'Usage: docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output cafernandezlo/dock-tools:v1.0 [experimentType] [OPTIONS]'
  echo ''
  echo 'INFO:'
  echo '  -v $PWD/input:/input   Mounts the local input directory to the container /input directory.'
  echo '  -v $PWD/output:/output Mounts the local output directory to the container /output directory.'
  echo ''
  echo 'The paths enable data to be shared between your host machine and the Docker container, allowing you'
  echo 'to provide input files and retrieve output files easily.'
  echo ''
  echo 'Experiment Type:'
  echo '   vina (executes Vina version 1.2.6)'
  echo '      Input Parameters:'
  echo '        receptor.pdb (receptor file)'
  echo '        ligand.sdf (ligand file)'
  echo '        You must choose either --box_enveloping or both --box_size and --box_center'
  echo ''
  echo '        --box_enveloping (requires padding; cannot be used with --box_size and --box_center)'
  echo '        --padding (default: 2.0)'
  echo '        --box_size (followed by three positive numbers)'
  echo '        --box_center (followed by three numbers)'
  echo '        --no-preprocessing (receptor processing with pdb4amber, maintaining --model 1)'
  echo '        --vre (to be executed on the VRE of d4science)'
  echo '        --cpu (default: 2)'
  echo '        --exhaustiveness (default: 10)'
  echo '        --verbosity (default: 2)'
  echo '        --seed (default: 1367858384)'
  echo '        --scoring (default: vina). Options: vina, ad4'
  echo ''
  echo 'Example Vina:'
  echo '   Automatically generate box with --box_enveloping:'
  echo '   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output cafernandezlo/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_enveloping'
  echo ''
  echo '   Manually define box with --box_size and --box_center:'
  echo '   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output cafernandezlo/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_size 10 10 10.1 --box_center 11 -12 13'
  echo ''
  echo '   Manually defined options:'
  echo '   docker run -it --rm -v $PWD/input:/input -v $PWD/output:/output cafernandezlo/dock-tools:v1.0 vina 2mm3.pdb Abemaciclib.sdf --box_size 10 10 10.1 --box_center 11 -12 13 --cpu 20 --exhaustiveness 30 --verbosity 4 --seed 1234 --scoring ad4'
  echo ''
  echo 'Maintainers:'
  echo '   - Carlos Fernandez-Lozano <carlos.fernandez@udc.es>'
  echo '   - Francisco Cedrón Santaeufemia <francisco.cedron@udc.es>'
  echo '   - Diego Fernández-Edreira <diego.fedreira@udc.es>'
  echo ''
  echo 'RePo-SUDOE Project. URL: https://interreg-sudoe.eu/proyecto-interreg/repo-sudoe/'
  echo ''
  echo 'Beneficiaries:'
  echo '   Instituto Politécnico da Guarda (Portugal)'
  echo '   Universidade da Coruña (Spain)'
  echo '   Universidade de Santiago de Compostela (Spain)'
  echo '   Centre National de la Recherche Scientifique (France)'
  echo '   MD.USE Innovations S.L. (Spain)'
  echo '   Sociedade Portuguesa de Saúde Pública (Portugal)'
  echo '   Asociación Cluster Saúde de Galicia (Spain)'
  echo ''
  echo 'Associated partners:'
  echo '   Servizo Galego de Saúde. Dirección Xeral de Asistencia Sanitaria (Spain)'
  echo '   Centro Académico Clínico das Beiras (Portugal)'
  echo '   Cancéropôle (France)'
}

# Default parameter handling
params_common=""

if [ -z "$has_exhaustiveness" ]; then
  params_common+=" --exhaustiveness 10"
fi
if [ -z "$has_seed" ]; then
  params_common+=" --seed 1367858384"
fi
if [ -z "$has_cpu" ]; then
  params_common+=" --cpu 2"
fi
if [ -z "$has_verbosity" ]; then
  params_common+=" --verbosity 2"
fi

check_arguments() {
  if [[ $# -lt 4 ]]; then
    echo "USAGE:"
    echo "  vina receptor.pdb ligand.sdf [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --box_enveloping   Automatically generate box; cannot be used with --box_size and --box_center."
    echo "  --box_size         Define box size; must be followed by three positive numbers."
    echo "  --box_center       Define box center; must be followed by three numbers."
    exit 1
  fi

  local receptor_file="$2"
  local ligand_file="$3"

  if [[ "${receptor_file##*.}" != "pdb" ]]; then
    echo "ERROR: The receptor file must have a .pdb extension."
    exit 1
  fi

  if [[ "${ligand_file##*.}" != "sdf" ]]; then
    echo "ERROR: The ligand file must have a .sdf extension."
    exit 1
  fi

  echo "INFO: Correct number of arguments and file extensions."
}

validate_box_parameters() {
  local all_args=("$@")
  local use_enveloping=false
  local has_size=false
  local has_center=false
  local size_values=0
  local center_values=0

  for ((i=0; i<${#all_args[@]}; i++)); do
    case "${all_args[i]}" in
      --box_enveloping)
        use_enveloping=true
        ;;
      --box_size)
        has_size=true
        for ((j=1; j<=3; j++)); do
          if [[ "${all_args[i+j]}" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "${all_args[i+j]} > 0" | awk '{print ($0 > 0)}') )); then
            size_values=$((size_values+1))
          fi
        done
        ;;
      --box_center)
        has_center=true
        for ((j=1; j<=3; j++)); do
          if [[ "${all_args[i+j]}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            center_values=$((center_values+1))
          fi
        done
        ;;
    esac
  done

  if $use_enveloping; then
    if $has_size || $has_center; then
      echo "ERROR: --box_enveloping cannot be used with --box_size or --box_center."
      exit 1
    fi
  else
    if ! $has_size || [ $size_values -ne 3 ]; then
      echo "ERROR: --box_size followed by three positive numbers is required."
      exit 1
    fi
    if ! $has_center || [ $center_values -ne 3 ]; then
      echo "ERROR: --box_center followed by three numbers is required."
      exit 1
    fi
  fi
}

eval "$(micromamba shell hook --shell bash)"
micromamba activate

case $1 in
  vina|VINA)
    check_arguments "$@"
    validate_box_parameters "$@"
    bash vina.sh "$@"
    ;;
  *)
    usage
    ;;
esac