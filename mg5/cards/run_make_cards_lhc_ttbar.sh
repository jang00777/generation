#!/bin/bash

procs=( "bbbar" "bsbar" "sbbar" "bdbar" "dbbar" )
addjet=( "2" )
energy=( "13" )
channels=( "2l" "1lp" "1lm" "0l" )
uncs=( "nominal" "mtop171p5" "mtop173p5" "mtop169p5" "mtop175p5" )

for e in ${energy[@]}; do
  for nj in ${addjet[@]}; do
    for proc in ${procs[@]}; do
      for ch in ${channels[@]}; do
        for unc in ${uncs[@]}; do
          if [[ ${unc} == "nominal" ]]; then
            cmd="python3 make_cards_lhc_ttbar.py -e ${e} -s ${proc} -c ${ch} -j ${nj}"
          else
            cmd="python3 make_cards_lhc_ttbar.py -e ${e} -s ${proc} -c ${ch} -j ${nj} --set_params ${unc}"
          fi
          echo ${cmd}
          ${cmd}
        done
      done
    done
  done
done
