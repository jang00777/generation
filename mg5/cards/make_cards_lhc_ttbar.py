import os
#import optparse as op
import argparse as ap

parser = ap.ArgumentParser()
parser.add_argument("-p", "--process", default="tt", dest="proc")
parser.add_argument("-j", "--additional_jet", default=2, dest="addjet", type=int)
parser.add_argument("-s", "--subproc", default="bbbar", dest="subproc")
parser.add_argument("-c", "--channel", default="2l", dest="channel")
parser.add_argument("-f", "--max_flavour", default=5, dest="flav", type=int)
parser.add_argument("-m", "--import_module", default="loop_sm-ckm_no_b_mass", dest="module")
parser.add_argument("-a", "--accuracy", default="NLO_FXFX", dest="acc")
parser.add_argument("-n", "--nevents", default=2000, type=int)
parser.add_argument("-e", "--energy", default=13, type=float)
parser.add_argument("--pdf", default="NNPDF3p1", dest="pdf")
parser.add_argument("--set_params", nargs="+", default=[])
parser.add_argument("--path", default=None)
#opts, args = parser.parse_args()
opts = parser.parse_args()

#################################################################################################

name_proc = opts.proc
name_addjet = "".join([str(ij) for ij in range(opts.addjet+1)])+"j"
name_subproc = opts.subproc
channel = opts.channel
name_flav = f"{opts.flav}f"
name_module = ""
name_acc = opts.acc
name_pdf = opts.pdf

nevents = opts.nevents
beam_energy = int((opts.energy*1000)/2.) # in GeV
name_energy = f"{str(opts.energy).replace('.','p').replace('p0','')}TeV"

if "ckm" in opts.module: name_module = "ckm"

if "FXFX" in name_acc:  ickkw = 3
elif "MLM" in name_acc: ickkw = 1
else:                   ickkw = 0

if opts.path == None:
    base_path = f"{os.environ['PWD']}/{name_energy}/{name_proc}{name_addjet}_{channel}_{name_flav}_{name_module}_{name_acc}_{name_pdf}"
else:
    base_path = opts.path

base_path = base_path.replace("__", "_")

madspin_wdecay = ""
if channel == "2l":    madspin_wdecay="define decay_t = ell+ ell- nu nubar\ndefine decay_tbar = ell+ ell- nu nubar"
elif channel == "1lp": madspin_wdecay="define decay_t = ell+ ell- nu nubar\ndefine decay_tbar = j"
elif channel == "1lm": madspin_wdecay="define decay_t = j\ndefine decay_tbar = ell+ ell- nu nubar"
elif channel == "0l":  madspin_wdecay="define decay_t = j\ndefine decay_tbar = j"
elif channel == "inclusive": madspin_wdecay="define decay_t = j ell+ ell- nu nubar\ndefine decay_tbar = j ell+ ell- nu nubar"
else:
    print("Process name should include description of final state channel !!! 2l (dilepton) / 1lp or 1lm (lepton+jet) / 0l (All-jet) / inclusive (All)")
    print("Also, semileptonic process should include sign of lepton !!! 1lp: t -> W+- > l+ nu / 1lm: tbar -> W- -> l- nu")
    exit()

# bbbar / bsbar/ sbbar / bdbar / dbbar
tq = name_subproc.split("bar")[0][0]
tqbar = name_subproc.split("bar")[0][1]
madspin_decays_t = f"decay t > w+ {tq}, w+ > decay_t decay_t"
madspin_decays_tbar = f"decay t~ > w- {tqbar}~, w- > decay_tbar decay_tbar"

#################################################################################################

default_proc_card=f"""
import model {opts.module}

define p = u d c s b u~ d~ c~ s~ b~ g
define j = p
define ell+ = e+ mu+ ta+
define ell- = e- mu- ta-
define nu = ve vm vt
define nubar = ve~ vm~ vt~

generate p p > t t~ [QCD] @0
"""
#"""
#add process p p > t t~ j [QCD] @1
#add process p p > t t~ j j [QCD] @2
#"""

default_customizedcards="""
set param_card mass 6 172.5
set param_card mass 25 125.0
set param_card yukawa 6 172.5
"""

default_run_card=f"""
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
  {nevents} = nevents ! Number of unweighted events requested
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
 {beam_energy}   = ebeam1  ! beam 1 energy in GeV
 {beam_energy}   = ebeam2  ! beam 2 energy in GeV
#***********************************************************************
# PDF choice: this automatically fixes also alpha_s(MZ) and its evol.  *
#***********************************************************************
 lhapdf    = pdlabel   ! PDF set
 $DEFAULT_PDF_SETS    = lhaid     ! if pdlabel=lhapdf, this is the lhapdf number
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
 {ickkw}        = ickkw            ! 0 no merging, 3 FxFx merging
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
 {opts.flav} = maxjetflavor
#***********************************************************************
"""

default_madspin_card=f"""
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
set Nevents_for_max_weight 250 # number of events for the estimate of the max. weight
set max_weight_ps_point 400  # number of PS to estimate the maximum for each event

#to properly limit the number of concurrent processes for grid running
set max_running_process 1

{madspin_wdecay}

# specify the decay for the final state particles
{madspin_decays_t}
{madspin_decays_tbar}

# running the actual code
launch
"""

#################################################################################################

proc_card = default_proc_card
customizedcards = default_customizedcards
run_card = default_run_card
madspin_card = default_madspin_card

sample_name = f"{name_proc}{name_addjet}_{name_subproc}_{channel}_{name_flav}_{name_module}_{name_acc}_{name_pdf}" 
sample_name = sample_name.replace("__", "_")

jet = "j "
for ij in range(1, opts.addjet+1):
  num = ij
  add_jet = jet*ij
  proc_card += f"add process p p > t t~ {add_jet}[QCD] @{num}\n"

name_mtop = ""
if len(opts.set_params) > 0:
    for param in opts.set_params:
        if "mtop" in param:
            new_mtop = param.split("mtop")[1].replace("p", ".")
            customizedcards = customizedcards.replace("6 172.5", f"6 {new_mtop}")
            name_mtop = param 

if name_mtop != "":
    sample_name = sample_name.replace(f"{channel}", f"{channel}_{name_mtop}")

proc_card += f"output {sample_name} -nojpeg"

#################################################################################################

path_to_write = f"{base_path}/{sample_name}/"
if not os.path.exists(path_to_write):
    print(f"There's no directory {path_to_write} ... make it")
    os.makedirs(path_to_write, exist_ok=True)

#################################################################################################

name_run_card = f"{path_to_write}/{sample_name}_run_card.dat"
name_proc_card = f"{path_to_write}/{sample_name}_proc_card.dat"
name_customizedcards = f"{path_to_write}/{sample_name}_customizedcards.dat"
name_madspin_card = f"{path_to_write}/{sample_name}_madspin_card.dat"

def write_card(fname: str, contents: str):
    f = open(fname, "w")
    f.write(contents)
    f.close()

write_card(name_run_card, run_card)
write_card(name_proc_card, proc_card)
write_card(name_customizedcards, customizedcards)
write_card(name_madspin_card, madspin_card)
