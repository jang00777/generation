#!/bin/sh

#./gridpack_generation.sh tt012j_bbars_2l_FxFx cards/tt012j_2l_FxFx/tt012j_bbars_2l_FxFx
#./gridpack_generation.sh tt012j_bsbar_2l_FxFx cards/tt012j_2l_FxFx/tt012j_bsbar_2l_FxFx
#./gridpack_generation.sh tt012j_bbbar_2l_FxFx cards/tt012j_2l_FxFx/tt012j_bbbar_2l_FxFx

#./gridpack_generation.sh tt012j_bbars_2l_FxFx_mtop171p5 cards/tt012j_2l_FxFx/tt012j_bbars_2l_FxFx_mtop171p5 
#./gridpack_generation.sh tt012j_bsbar_2l_FxFx_mtop171p5 cards/tt012j_2l_FxFx/tt012j_bsbar_2l_FxFx_mtop171p5 
#./gridpack_generation.sh tt012j_bbbar_2l_FxFx_mtop171p5 cards/tt012j_2l_FxFx/tt012j_bbbar_2l_FxFx_mtop171p5 
#./gridpack_generation.sh tt012j_bbars_2l_FxFx_mtop173p5 cards/tt012j_2l_FxFx/tt012j_bbars_2l_FxFx_mtop173p5 
#./gridpack_generation.sh tt012j_bsbar_2l_FxFx_mtop173p5 cards/tt012j_2l_FxFx/tt012j_bsbar_2l_FxFx_mtop173p5 
#./gridpack_generation.sh tt012j_bbbar_2l_FxFx_mtop173p5 cards/tt012j_2l_FxFx/tt012j_bbbar_2l_FxFx_mtop173p5 

#./gridpack_generation.sh tt012j_bbard_2l_FxFx cards/tt012j_2l_FxFx/tt012j_bbard_2l_FxFx
#./gridpack_generation.sh tt012j_bdbar_2l_FxFx cards/tt012j_2l_FxFx/tt012j_bdbar_2l_FxFx

gridpack_script="./gridpack_generation.sh"
path_ttbar="$PWD/cards/Run2UL_TTBar"
path_ttbar="cards/Run2UL_TTBar"

parton_flavor=( "BBbar" "BSbar" "SBbar" "BDbar" "DBbar" )
channel=( "2L2Nu" "SemiLeptonicPL" "SemiLeptonicML" "Hadronic" )
other_setup="TuneCP5_13TeV-amcatnloFxFx-pythia8"

patch_path="$PWD/patches/decay_threshold.patch"

for ch in ${channel[@]}; do
  for flav in ${parton_flavor[@]}; do
    if [[ ${ch} == "SemiLeptonicPL" ]]; then
      proc="TTToSemiLeptonic${flav}PL_${other_setup}"
    elif [[ ${ch} == "SemiLeptonicML" ]]; then
      proc="TTToSemiLeptonic${flav}ML_${other_setup}"
    else
      proc="TTTo${ch}${flav}_${other_setup}"
    fi

    echo "------------ START ${proc} -------------"

    if [[ -d GRIDPACK_TT/${proc} || -d ./${proc} ]]; then
      echo "=====================> ${proc} was already produced, skip this"
      continue
    fi


    if [[ ${flav} =~ "D" ]]; then
      echo "======================> Patch decay width and BR values less than QCD scale for allowing tdW decays"
      patch_cmd="cp $PWD/patches_for_private/tdW_decay_threshold.patch ${patch_path}"
    else
      echo "======================> Patch decay width and BR values less than QCD scale for allowing tsW decays (This patch is also applied to bbbar case for consistency)"
      patch_cmd="cp $PWD/patches_for_private/tsW_decay_threshold.patch ${patch_path}"
    fi

    echo "======================> ${patch_cmd}"
    $patch_cmd

    cmd="${gridpack_script} ${proc} ${path_ttbar}/${proc//[A-Z][A-Z]bar/QQbar}/${proc}"
    $cmd

    echo "=========================> Clean up user-specific patches: ${patch_path}"
    #rm $PWD/patches/0031-fix_madspin_when_msdir_activated.patch
    rm $PWD/patches/decay_threshold.patch
  done
done

#./gridpack_generation.sh TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#
#./gridpack_generation.sh TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#
#./gridpack_generation.sh TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBSbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuSBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuBDbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
#./gridpack_generation.sh TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8 ${path_ttbar}/TTTo2L2NuQQBar_TuneCP5_13TeV_amcatnloFxFx-pythia8/TTTo2L2NuDBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8
