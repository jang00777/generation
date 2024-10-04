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
path_ttbar="$PWD/cards/Run2UL_TTBar/13TeV"
path_ttbar="cards/Run2UL_TTBar/13TeV"

parton_flavor=( "bbbar" "bsbar" "sbbar" "bdbar" "dbbar" )
channel=( "2l" "1lp" "1lm" "0l" )
other_setup="5f_ckm_NLO_FXFX_NNPDF3p1"

uncs=( "nominal" "mtop171p5" "mtop173p5" )

patch_path="$PWD/patches/decay_threshold.patch"

#drwxr-xr-x 2 wjang zh 266 Oct  5 00:29 cards/Run2UL_TTBar/13TeV/tt012j_1lm_NLO_FXFX_NNPDF3p1/tt012j_bbbar_1lm_5f_ckm_NLO_FXFX_NNPDF3p1
#drwxr-xr-x 2 wjang zh 306 Oct  5 00:29 cards/Run2UL_TTBar/13TeV/tt012j_1lm_NLO_FXFX_NNPDF3p1/tt012j_bbbar_1lm_mtop169p5_5f_ckm_NLO_FXFX_NNPDF3p1
#drwxr-xr-x 2 wjang zh 306 Oct  5 00:29 cards/Run2UL_TTBar/13TeV/tt012j_1lm_NLO_FXFX_NNPDF3p1/tt012j_bbbar_1lm_mtop171p5_5f_ckm_NLO_FXFX_NNPDF3p1
#drwxr-xr-x 2 wjang zh 306 Oct  5 00:29 cards/Run2UL_TTBar/13TeV/tt012j_1lm_NLO_FXFX_NNPDF3p1/tt012j_bbbar_1lm_mtop173p5_5f_ckm_NLO_FXFX_NNPDF3p1
#drwxr-xr-x 2 wjang zh 306 Oct  5 00:29 cards/Run2UL_TTBar/13TeV/tt012j_1lm_NLO_FXFX_NNPDF3p1/tt012j_bbbar_1lm_mtop175p5_5f_ckm_NLO_FXFX_NNPDF3p1

for unc in ${uncs[@]}; do
  for ch in ${channel[@]}; do
    proc_cat="tt012j_${ch}_${other_setup}"
    for flav in ${parton_flavor[@]}; do
      proc="tt012j_${flav}_${ch}_${other_setup}"

      if [[ ${unc} != "nominal" ]]; then
        proc=${proc//${other_setup}/${unc}_${other_setup}}
        if [[ ${flav} =~ "d" ]]; then
          continue
        fi
      fi

      echo "------------ START ${proc} -------------"
  
      if [[ -d GRIDPACK_TT/${proc} || -d ./${proc} ]]; then
        echo "=====================> ${proc} was already produced, skip this"
        continue
      fi
  
  
      if [[ ${flav} =~ "d" ]]; then
        echo "======================> Patch decay width and BR values less than QCD scale for allowing tdW decays"
        patch_cmd="cp $PWD/patches_for_private/tdW_decay_threshold.patch ${patch_path}"
      else
        echo "======================> Patch decay width and BR values less than QCD scale for allowing tsW decays (This patch is also applied to bbbar case for consistency)"
        patch_cmd="cp $PWD/patches_for_private/tsW_decay_threshold.patch ${patch_path}"
      fi
  
      echo "======================> ${patch_cmd}"
      $patch_cmd
  
      cmd="${gridpack_script} ${proc} ${path_ttbar}/${proc_cat}/${proc}"
      $cmd
  
      echo "=========================> Clean up user-specific patches: ${patch_path}"
      #rm $PWD/patches/0031-fix_madspin_when_msdir_activated.patch
      rm $PWD/patches/decay_threshold.patch
    done
  done
done

