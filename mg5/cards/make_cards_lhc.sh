#!/bin/sh


echo "================Make MG5 generation cards================="
echo "date: $(date)"
echo "hostname: $(hostname)"
echo "whoami: $(whoami)"
echo "pwd: $(pwd)"

ls -al

#TIME_NOW="$(date +"%x %r %Z")"
#TIME_STAMP="Updated on $TIME_NOW by $USER"

##### Functions

usage()
{
    echo "usage: make_cards_lhc.sh [[[-p/--process <PROCESS>] [-n/--nevent <NEVENT> ] [-e/--energy <ENERGY_IN_TEV>] | [-h/--help]]"
}

# Currently process option is not implemented yet
process="ttbar"
nevents=2000
energy=13

while [ "$1" != "" ]; do
    case $1 in
        -p | --process)         shift
                                process=$1
                                echo "process_to_generate = ${process}"
                                ;;
        -n | --nevents)         shift
                                nevents=$1
                                echo "events_to_generate = ${nevents}"
                                ;;
        -e | --energy)          shift
                                energy=$1
                                echo "sqrt(s) = ${energy} TeV"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

energy_beam1_gev=$( echo "scale=0; ${energy}*1000/2" | bc )
energy_beam2_gev=$( echo "scale=0; ${energy}*1000/2" | bc )
energy_title=${energy//./p}


#proc_list=(
#  "TTTo2L2NuBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8"
#  "TTToSemiLeptonicBBbarPL_TuneCP5_13TeV-amcatnloFxFx-pythia8"
#  "TTToSemiLeptonicBBbarML_TuneCP5_13TeV-amcatnloFxFx-pythia8"
#  "TTToHadronicBBbar_TuneCP5_13TeV-amcatnloFxFx-pythia8"
#)

script_proc_card="
#import model loop_sm-no_b_mass
import model loop_sm-ckm_no_b_mass

define p = u d c s b u~ d~ c~ s~ b~ g
define j = p
define ell+ = e+ mu+ ta+
define ell- = e- mu- ta-
define nu = ve vm vt
define nubar = ve~ vm~ vt~

generate p p > t t~ [QCD] @0
add process p p > t t~ j [QCD] @1
add process p p > t t~ j j [QCD] @2
"

script_customizedcards="
#put card customizations here (change top and higgs mass for example)
set param_card mass 6 172.5
set param_card mass 25 125.0
set param_card yukawa 6 172.5
#set wolfenstein elements high enough for t>sW to be generated (above QCD scale)
# Sufficient to set lam (elt 1)
#set param_card wolfenstein 1 0.85
"

script_run_card="
#***********************************************************************
#                        MadGraph5_aMC@NLO                             *
#                                                                      *
#                      run_card.dat aMC@NLO                            *
#                                                                      *
#  This file is used to set the parameters of the run.                 *
#                                                                      *
#  Some notation/conventions:                                          *
#                                                                      *
#   Lines starting with a hash (#) are info or comments                *
#                                                                      *
#   mind the format:   value    = variable     ! comment               *
#***********************************************************************
#
#*******************
# Running parameters
#*******************
#
#***********************************************************************
# Tag name for the run (one word)                                      *
#***********************************************************************
  tag_1     = run_tag ! name of the run
#***********************************************************************
# Number of events (and their normalization) and the required          *
# (relative) accuracy on the Xsec.                                     *
# These values are ignored for fixed order runs                        *
#***********************************************************************
  ${nevents} = nevents ! Number of unweighted events requested
 0.001 = req_acc ! Required accuracy (-1=auto determined from nevents)
  -1 = nevt_job! Max number of events per job in event generation.
                 !  (-1= no split).
average = event_norm ! Normalize events to sum or average to the X sect.
#***********************************************************************
# Number of points per itegration channel (ignored for aMC@NLO runs)   *
#***********************************************************************
 0.01   = req_acc_FO       ! Required accuracy (-1=ignored, and use the
                           ! number of points and iter. below)
# These numbers are ignored except if req_acc_FO is equal to -1
 5000   = npoints_FO_grid  ! number of points to setup grids
 4      = niters_FO_grid   ! number of iter. to setup grids
 10000  = npoints_FO       ! number of points to compute Xsec
 6      = niters_FO        ! number of iter. to compute Xsec
#***********************************************************************
# Random number seed                                                   *
#***********************************************************************
     0    = iseed       ! rnd seed (0=assigned automatically=default))
#***********************************************************************
# Collider type and energy                                             *
#***********************************************************************
    1   = lpp1    ! beam 1 type (0 = no PDF)
    1   = lpp2    ! beam 2 type (0 = no PDF)
 ${energy_beam1_gev}   = ebeam1  ! beam 1 energy in GeV
 ${energy_beam2_gev}   = ebeam2  ! beam 2 energy in GeV
#***********************************************************************
# PDF choice: this automatically fixes also alpha_s(MZ) and its evol.  *
#***********************************************************************
 lhapdf    = pdlabel   ! PDF set
 \$DEFAULT_PDF_SETS    = lhaid     ! if pdlabel=lhapdf, this is the lhapdf number
#***********************************************************************
# Include the NLO Monte Carlo subtr. terms for the following parton    *
# shower (HERWIG6 | HERWIGPP | PYTHIA6Q | PYTHIA6PT | PYTHIA8)         *
# WARNING: PYTHIA6PT works only for processes without FSR!!!!          *
#***********************************************************************
  PYTHIA8   = parton_shower
#***********************************************************************
# Renormalization and factorization scales                             *
# (Default functional form for the non-fixed scales is the sum of      *
# the transverse masses of all final state particles and partons. This *
# can be changed in SubProcesses/set_scales.f)                         *
#***********************************************************************
 F        = fixed_ren_scale  ! if .true. use fixed ren scale
 F        = fixed_fac_scale  ! if .true. use fixed fac scale
 91.188   = muR_ref_fixed    ! fixed ren reference scale
 91.188   = muF1_ref_fixed   ! fixed fact reference scale for pdf1
 91.188   = muF2_ref_fixed   ! fixed fact reference scale for pdf2
#***********************************************************************
# Renormalization and factorization scales (advanced and NLO options)  *
#***********************************************************************
 F        = fixed_QES_scale  ! if .true. use fixed Ellis-Sexton scale
 91.188   = QES_ref_fixed    ! fixed Ellis-Sexton reference scale
 1        = muR_over_ref     ! ratio of current muR over reference muR
 1        = muF1_over_ref    ! ratio of current muF1 over reference muF1
 1        = muF2_over_ref    ! ratio of current muF2 over reference muF2
 1        = QES_over_ref     ! ratio of current QES over reference QES
#***********************************************************************
# Reweight flags to get scale dependence and PDF uncertainty           *
# For scale dependence: factor rw_scale_up/down around central scale   *
# For PDF uncertainty: use LHAPDF with supported set                   *
#***********************************************************************
 .true.   = reweight_scale   ! reweight to get scale dependence
  0.5     = rw_Rscale_down   ! lower bound for ren scale variations
  2.0     = rw_Rscale_up     ! upper bound for ren scale variations
  0.5     = rw_Fscale_down   ! lower bound for fact scale variations
  2.0     = rw_Fscale_up     ! upper bound for fact scale variations
 \$DEFAULT_PDF_MEMBERS  = reweight_PDF     ! reweight to get PDF uncertainty
#***********************************************************************
# Merging - WARNING! Applies merging only at the hard-event level.     *
# After showering an MLM-type merging should be applied as well.       *
# See http://amcatnlo.cern.ch/FxFx_merging.htm for more details.       *
#***********************************************************************
 3        = ickkw            ! 0 no merging, 3 FxFx merging
#***********************************************************************
#
#***********************************************************************
# BW cutoff (M+/-bwcutoff*Gamma)                                       *
#***********************************************************************
 15  = bwcutoff
#***********************************************************************
# Cuts on the jets                                                     *
# Jet clustering is performed by FastJet.
# When matching to a parton shower, these generation cuts should be    *
# considerably softer than the analysis cuts.                          *
# (more specific cuts can be specified in SubProcesses/cuts.f)         *
#***********************************************************************
   1  = jetalgo   ! FastJet jet algorithm (1=kT, 0=C/A, -1=anti-kT)
 1.0  = jetradius ! The radius parameter for the jet algorithm
  20  = ptj       ! Min jet transverse momentum
  -1  = etaj      ! Max jet abs(pseudo-rap) (a value .lt.0 means no cut)
#***********************************************************************
# Cuts on the charged leptons (e+, e-, mu+, mu-, tau+ and tau-)        *
# (more specific gen cuts can be specified in SubProcesses/cuts.f)     *
#***********************************************************************
   0  = ptl     ! Min lepton transverse momentum
  -1  = etal    ! Max lepton abs(pseudo-rap) (a value .lt.0 means no cut)
   0  = drll    ! Min distance between opposite sign lepton pairs
   0  = drll_sf ! Min distance between opp. sign same-flavor lepton pairs
   0  = mll     ! Min inv. mass of all opposite sign lepton pairs
  30  = mll_sf  ! Min inv. mass of all opp. sign same-flavor lepton pairs
#***********************************************************************
# Photon-isolation cuts, according to hep-ph/9801442                   *
# When ptgmin=0, all the other parameters are ignored                  *
#***********************************************************************
  20  = ptgmin    ! Min photon transverse momentum
  -1  = etagamma  ! Max photon abs(pseudo-rap)
 0.4  = R0gamma   ! Radius of isolation code
 1.0  = xn        ! n parameter of eq.(3.4) in hep-ph/9801442
 1.0  = epsgamma  ! epsilon_gamma parameter of eq.(3.4) in hep-ph/9801442
 .true.  = isoEM  ! isolate photons from EM energy (photons and leptons)
#***********************************************************************
# Maximal PDG code for quark to be considered a jet when applying cuts.*
# At least all massless quarks of the model should be included here.   *
#***********************************************************************
 5 = maxjetflavor
#***********************************************************************
"

function write_scripts() {
  local process=$1
  local base_path=$2

  path_to_write=${base_path}/${process//[A-Z][A-Z]bar/QQbar}/${process}
  if [[ ! -d ${path_to_write} ]]; then
    echo "No directory of ${path_to_write} ---> Create it"
    mkdir -p ${path_to_write}
  fi

  # Default - None
  madspin_wdecay=""

  if [[ ${process} =~ "2L2Nu" ]]; then
    madspin_wdecay="define decay_t = ell+ ell- nu nubar\ndefine decay_tbar = ell+ ell- nu nubar"
  elif [[ ${process} =~ "SemiLeptonic" ]]; then
    if [[ ${process} =~ "PL_" ]]; then
      madspin_wdecay="define decay_t = ell+ ell- nu nubar\ndefine decay_tbar = j"
    elif [[ ${process} =~ "ML_" ]]; then
      madspin_wdecay="define decay_t = j\ndefine decay_tbar = ell+ ell- nu nubar"
    else
      echo "Semileptonic process shoud include sign of lepton !!! TTToSemiLeptonic*PL(ML)_* (PL: t -> W+- > l+ nu / ML: tbar -> W- -> l- nu)"
      exit 8
    fi
  elif [[ ${process} =~ "Hadronic" ]]; then
    madspin_wdecay="define decay_t = j\ndefine decay_tbar = j"
  elif [[ ${process} =~ "Inclusive" ]]; then
    madspin_wdecay="define decay_t = j ell+ ell- nu nubar\ndefine decay_tbar = j ell+ ell- nu nubar"
  else
    echo "process name should include description of final state channel !!! TTTo2L2Nu* (DL) / TTToSemiLeptonic* (SL) / TTToHadronic* (HAD) / TTToInclusive (All)"
    exit 9
  fi

  # Default - None
  madspin_decays_t=""
  madspin_decays_tbar=""

  if [[ ${process} == TTTo*@(B?bar)* ]]; then
    madspin_decays_t="decay t > w+ b, w+ > decay_t decay_t"
  elif [[ ${process} == TTTo*@(S?bar)* ]]; then
    madspin_decays_t="decay t > w+ s, w+ > decay_t decay_t"
  elif [[ ${process} == TTTo*@(D?bar)* ]]; then
    madspin_decays_t="decay t > w+ d, w+ > decay_t decay_t"
  fi

  if [[ ${process} == TTTo*@(?Bbar)* ]]; then
    madspin_decays_tbar="decay t~ > w- b~, w- > decay_tbar decay_tbar"
  elif [[ ${process} == TTTo*@(?Sbar)* ]]; then
    madspin_decays_tbar="decay t~ > w- s~, w- > decay_tbar decay_tbar"
  elif [[ ${process} == TTTo*@(?Dbar)* ]]; then
    madspin_decays_tbar="decay t~ > w- d~, w- > decay_tbar decay_tbar"
  fi


  script_madspin_card="
#************************************************************
#*                        MadSpin                           *
#*                                                          *
#*    P. Artoisenet, R. Frederix, R. Rietkerk, O. Mattelaer *
#*                                                          *
#*    Part of the MadGraph5_aMC@NLO Framework:              *
#*    The MadGraph5_aMC@NLO Development Team - Find us at   *
#*    https://server06.fynu.ucl.ac.be/projects/madgraph     *
#*                                                          *
#************************************************************
#Some options (uncomment to apply)

#directory for gridpack mode
set ms_dir ./madspingrid

#initialization parameters
set Nevents_for_max_weigth 250 # number of events for the estimate of the max. weight
set max_weight_ps_point 400  # number of PS to estimate the maximum for each event

#to properly limit the number of concurrent processes for grid running
set max_running_process 1

${madspin_wdecay}  

# specify the decay for the final state particles
${madspin_decays_t}
${madspin_decays_tbar}

# running the actual code
launch
"
 
  local local_script_proc_card="${script_proc_card}\noutput ${process} -nojpeg"

  echo -e "${local_script_proc_card}" > ${path_to_write}/${process}_proc_card.dat
  echo -e "${script_customizedcards}" > ${path_to_write}/${process}_customizecards.dat
  echo -e "${script_madspin_card}"    > ${path_to_write}/${process}_madspin_card.dat
  echo -e "${script_run_card}"        > ${path_to_write}/${process}_run_card.dat
}


parton_flavor=( "BBbar" "BSbar" "SBbar" "BDbar" "DBbar" )
channel=( "2L2Nu" "SemiLeptonicPL" "SemiLeptonicML" "Hadronic" )
other_setup="TuneCP5_${energy_title}TeV-amcatnloFxFx-pythia8"
base_path="$PWD/${energy_title}TeV"

if [[ ! -d ${base_path} ]]; then
  echo "Create ${base_path} for saving cards ..."
  mkdir -p ${base_path}
fi

for ch in ${channel[@]}; do
  for flav in ${parton_flavor[@]}; do
    if [[ ${ch} == "SemiLeptonicPL" ]]; then
      proc="TTToSemiLeptonic${flav}PL_${other_setup}"
    elif [[ ${ch} == "SemiLeptonicML" ]]; then
      proc="TTToSemiLeptonic${flav}ML_${other_setup}"
    else
      proc="TTTo${ch}${flav}_${other_setup}"
    fi
    write_scripts ${proc} ${base_path}
  done
done




