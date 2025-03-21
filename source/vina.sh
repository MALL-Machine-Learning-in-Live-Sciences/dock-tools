#!/bin/bash
export params_common=""
export params_box=""
export scoring="vina"
export padding=2.0
export has_exhaustiveness=false
export has_verbosity=false
export has_seed=false
export has_cpu=false
export is_vre=false
export use_enveloping=false

export receptor_name=$(basename "${2%.pdb}")
export ligando_name=$(basename "${3%.sdf}")
export receptor_pdb=/app/${receptor_name}.pdb
export receptor_pdbqt=/app/${receptor_name}.pdbqt
export receptor_box=/app/${receptor_name}.box.txt
export ligando_sdf=/app/${ligando_name}.sdf
export ligando_pdbqt=/app/${ligando_name}.pdbqt
export gpf_file=/app/${receptor_name}.gpf
export glg_file=/app/${receptor_name}.glg
export map_file=/app/${receptor_name}
export output_pdbqt=/app/${receptor_name}_${ligando_name}_out.pdbqt
export log_file=/app/${receptor_name}_${ligando_name}_vina.log

if [ ! -f "/input/$2" ]; then
        echo "ERROR: /input/$2 does not exist."
        exit 1
fi

if [ ! -f "/input/$3" ]; then
        echo "ERROR: /input/$3 doese not exist."
        exit 1
fi

original_args="$*"
all_args="$*"

read -r _ arg1 arg2 _ <<< "$all_args"
cp /input/$arg1 $receptor_pdb
cp /input/$arg2 $ligando_sdf

mk_prepare_ligand.py -i $ligando_sdf -o $ligando_pdbqt

case " $* " in
  *" --no-preprocessing "*) 
    echo "INFO: No preprocessing of the receptor." 
    ;;
  *) 
    echo "INFO: Using pdb4amber to clean the receptor (model 1)."
    pdb4amber -i $receptor_pdb -o ${receptor_name}_cleaned.pdb -p --model 1
    mv ${receptor_name}_cleaned.pdb $receptor_pdb
    ;;
esac

set -- $all_args

while [[ $# -gt 0 ]]; do
    case "$1" in
        --exhaustiveness)
            params_common+=" --exhaustiveness $2"
            has_exhaustiveness=true
            shift 2
            ;;
        --verbosity)
            params_common+=" --verbosity $2"
            has_verbosity=true
            shift 2
            ;;
        --seed)
            params_common+=" --seed $2"
            has_seed=true
            shift 2
            ;;
        --cpu)
            params_common+=" --cpu $2"
            has_cpu=true
            shift 2
            ;;
        --padding)
            padding="$2"
            shift 2
            ;;
        --vre)
            is_vre=true
            shift 1
            ;;
        --box_enveloping)
            use_enveloping=true
            shift 1
            ;;
        --box_size)
            params_box+=" --box_size $2 $3 $4"
            shift 4
            ;;
        --box_center)
            params_box+=" --box_center $2 $3 $4"
            shift 4
            ;;
        --scoring)
            scoring="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Completar con valores por defecto donde sea necesario
if ! $has_exhaustiveness; then
    params_common+=" --exhaustiveness 10"
fi
if ! $has_seed; then
    params_common+=" --seed 1367858384"
fi
if ! $has_cpu; then
    params_common+=" --cpu 2"
fi
if ! $has_verbosity; then
    params_common+=" --verbosity 2"
fi

case "$scoring" in
  vina)
    echo "INFO: scoring function (vina)."
    if $use_enveloping; then
	  echo "INFO: --box_enveloping selected."
	  mk_prepare_receptor.py --read_pdb $receptor_pdb -o ${receptor_name} -p -a -v \
	  --box_enveloping $ligando_pdbqt --padding $padding
	else
	  echo "INFO: box_size and box_center defined by user."
	  mk_prepare_receptor.py --read_pdb $receptor_pdb -o ${receptor_name} -p -a -v \
	  $params_box
    fi
    vina --ligand $ligando_pdbqt --receptor $receptor_pdbqt --scoring vina \
    --config $receptor_box --out $output_pdbqt \
    $params_common > $log_file 2>&1
    ;;
  ad4)
    echo "INFO: scoring function (ad4)."
    if $use_enveloping; then
	  echo "INFO: --box_enveloping selected."
	  mk_prepare_receptor.py --read_pdb $receptor_pdb -o ${receptor_name} -p -a -g \
	  --box_enveloping $ligando_pdbqt --padding $padding
	else
	  echo "INFO: box_size and box_center defined by user."
	  mk_prepare_receptor.py --read_pdb $receptor_pdb -o ${receptor_name} -p -a -g \
	  $params_box
    fi
    autogrid4 -p $gpf_file -l $glg_file
    vina --ligand $ligando_pdbqt --maps $map_file --scoring ad4 \
    --out $output_pdbqt \
    $params_common > $log_file 2>&1
    ;;
  *)
    echo "INFO: unknown scoring function: $scoring."
    exit 1
    ;;
esac

mk_export.py $output_pdbqt -s ${output_pdbqt}.sdf

if [ "$is_vre" = true ]; then
    cat $output_pdbqt > /output/output.pdbqt
    cat $log_file > /output/output_log.log
    cat ${output_pdbqt}.sdf > /output/output.pdbqt.sdf
else
    mv $log_file /output
    mv $receptor_pdbqt /output
    mv $output_pdbqt* /output
fi