"""
This module, with only one function "initialized_data(), initializes data related to 
substrate, monomer, enzyme, and microbe, as well as their distribution on the spatial grid,
preceding the actual decompostion-related computations.
"""
import pandas as pd
import numpy as np

from substrate import Substrate
from monomer   import Monomer
from enzyme    import Enzyme
from microbe   import Microbe
from utility   import expand



def initialize_data(runtime_parameters):
    """
    Parameters:
        runtime_parameters: user-specified parameters setting up the system;
                            all other paras loaded by reading the parameters.csv
    Return:
        Data_Dictionary: a dictionary of all variables that feeds the grid.py module
    """
    
    # Load all input files
    parameters      = pd.read_csv('parameters_cellulose.csv',         header=None, index_col=0).astype('float32')   # parameters
    substrates_init = pd.read_csv('initial_substrates_cellulose.csv', header=0,    index_col=0).astype('float32')   # initial substrates
    sub_mon_input   = pd.read_csv('sub_mon_inputs_cellulose.csv',     header=0,    index_col=0).astype('float32')   # inputs of substrates and monomers
    Ea_input        = pd.read_csv("enzyme_ea_cellulose.csv",          header=0,    index_col=0).astype('float32')   # enzyme activation energy
    climate         = pd.read_csv('climate_SP2.csv',            header=0,    index_col=0)                     # climate forcings

    # daily temperature and water potential
    daily_temp = climate['Temp'].astype('float32')  # temperaure series
    daily_psi  = climate['Psi'].astype('float32')   # water potential series


    #...an instance of Substrate class 
    Substrates = Substrate(runtime_parameters,parameters,substrates_init)
    #...substrate initial pool size
    substrates_initial_pool = Substrates.Substrates_start
    #...substrate input rate
    substrates_input_rate = Substrates.substrate_input(sub_mon_input)
    #...substrates-produced monomers
    substrates_produced_monomers = Substrates.substrate_produced_monomer()
    #...substrates degradation required enzymes
    substrates_req_enzyme = Substrates.substrate_degradation_enzyme()
    
    
    #...an instance of Monomer class
    Monomers = Monomer(runtime_parameters,parameters)
    #...monomers initial pool size
    monomers_initial_pool = Monomers.monomer_initialization(substrates_initial_pool)
    #...initial monomer ratios
    monomer_ratio_inital = Monomers.monomer_ratios(monomers_initial_pool)
    #...monomers input rate
    monomers_input_rate = Monomers.monomer_input_rate(sub_mon_input)
    #...monomers uptake required enzymes
    monomers_uptake_reqenzyme = Monomers.monomer_uptake_reqenzyme()
    
    
    #...an instance of Enzyme class
    Enzymes = Enzyme(runtime_parameters,parameters,substrates_initial_pool.index)
    #...enzyme initial pool size:0
    enzymes_initial_pool = Enzymes.enzyme_pool_initialization()
    #...enzyme attributes
    enzymes_attributes = Enzymes.enzyme_attributes()
    #...enzymes of substrate degradation Ea    
    enzymes_Ea = Enzymes.enzyme_Ea(Ea_input)
    #...monomers uptake enzyme Ea
    enzymes_uptake_Ea = Enzymes.enzyme_uptake_Ea()
    #...enzymes of substrate degradation Vmax
    enzymes_Vmax,enzymes_Vmax_T = Enzymes.enzyme_Vmax(substrates_req_enzyme)
    #...monomers uptake enzyme Vmax
    enzymes_uptake_Vmax= Enzymes.enzyme_uptake_Vmax(monomers_uptake_reqenzyme)
    #...enzymes of substrate degradation Km
    enzymes_Km = Enzymes.enzyme_Km(enzymes_Vmax)
    #...monomers uptake enzyme Km
    enzymes_uptake_Km = Enzymes.enzyme_uptake_Km(enzymes_uptake_Vmax)
    
     
    #...an instance of Microbe class
    Microbes = Microbe(runtime_parameters,parameters)
    #...Microbial community initialization#...note microbial_community is a tuple
    microbial_community = Microbes.microbial_community_initialization()
    #...Microbial minimum ratios
    microbial_min_ratios = Microbes.minimum_cell_quota()
    #...Microbial enzyme genes
    microbial_enzyme_gene = Microbes.microbe_enzyme_gene()
    #...Microbial osmolyte genes
    microbial_osmolyte_gene = Microbes.microbe_osmolyte_gene()
    #...Microbial uptake genes
    microbial_uptake_gene = Microbes.microbe_uptake_gene(substrates_req_enzyme,microbial_enzyme_gene,substrates_produced_monomers)
    #...Microbial uptake cost
    microbial_uptake_cost = Microbes.microbe_uptake_cost(microbial_uptake_gene)
    #...Microbial enzyme production rate
    microbial_enzyme_prod_rate = Microbes.microbe_enzproduction_rate(microbial_enzyme_gene,enzymes_attributes)
    #...Microbial osmolyte productoin rate
    microbial_osmolyte_prod_rate = Microbes.microbe_osmoproduction_rate(microbial_osmolyte_gene)
    #...Microbial drought tolerance
    microbial_drought_tol = Microbes.microbe_drought_tol(microbial_osmolyte_prod_rate[2],microbial_osmolyte_prod_rate[3])
    #...Microbial mortality
    microbial_mortality = Microbes.microbe_mortality(microbial_community[2])
    
    #...Dump all initialized data into a dictionary; NOTE: variables with expand() put on the spatial grid
    gridsize = int(runtime_parameters.loc['gridsize',1])
    
    Data_Dictionary = {"Substrates": expand(substrates_initial_pool,gridsize),
                       "SubInput":   expand(substrates_input_rate,gridsize),
                       "ReqEnz":           substrates_req_enzyme,
                       "MonomersProduced": substrates_produced_monomers,
                       "Monomers":     expand(monomers_initial_pool,gridsize),
                       "Monomer_ratio":expand(monomer_ratio_inital,gridsize),
                       "MonInput":     expand(monomers_input_rate,gridsize),
                       "Uptake_ReqEnz":expand(monomers_uptake_reqenzyme,gridsize),
                       "Enzymes":      expand(enzymes_initial_pool,gridsize),
                       "Km0":          expand(enzymes_Km,gridsize),            # enzyme half-saturation constant
                       "Uptake_Km0":   expand(enzymes_uptake_Km,gridsize),     # transporter half-saturation constant
                       "Uptake_Ea":    expand(enzymes_uptake_Ea,gridsize),     # transporter acitivation energy
                       "Uptake_Vmax0": expand(enzymes_uptake_Vmax,gridsize),   # transporter reaction rate
                       "Ea":           expand(enzymes_Ea,gridsize),            # enzyme activation energy
                       "Vmax0":        expand(enzymes_Vmax_T,gridsize),        # enzyme reaction rate
                       "EnzAttrib":    enzymes_attributes,                     # enzyme stoichiometry and energy cost
                       "Microbes_pp": microbial_community[0],                  # tuple[0]: microbes preceding placement
                       "Microbes":    microbial_community[1],                  # tuple[1]: initialized spatial microbes
                       "fb":          microbial_community[2],                  # tuple[2]: fungi index
                       "Bac_density": microbial_community[3],                  # tuple[3]: bacterial density
                       "Fun_density": microbial_community[4],                  # tuple[4]: fungi density
                       "MinRatios":   expand(microbial_min_ratios,gridsize),   # microbial cell min. ratios
                       "UptakeGenes": expand(microbial_uptake_gene,gridsize),  # transporter gene distribution across taxa
                       "OsmoGenes":   expand(microbial_osmolyte_gene,gridsize),# osmolyte gene distribution across taxa
                       "EnzGenes":    expand(microbial_enzyme_gene,gridsize),  # enzyme gene distribution across taxa
                       "UptakeGenes_trait":   expand(microbial_uptake_cost[0],gridsize),        # single gene cost of transporter
                       "OsmoProdConsti_trait":expand(microbial_osmolyte_prod_rate[0],gridsize), # single gene cost of constitutive osmolyte
                       "OsmoProdInduci_trait":expand(microbial_osmolyte_prod_rate[1],gridsize), # single gene cost of inducible osmolyte
                       "EnzProdConsti_trait": expand(microbial_enzyme_prod_rate[0],gridsize),   # single gene cost of constitutive enzyme
                       "EnzProdInduci_trait": expand(microbial_enzyme_prod_rate[1],gridsize),   # single gene cost of inducible enzyme
                       "UptakeGenesCost":     expand(microbial_uptake_cost[1],gridsize),        # distribution of transporter gene cost across taxa
                       "OsmoProdConsti":      expand(microbial_osmolyte_prod_rate[2],gridsize), # distribution of consti. osmolyte gene cost across taxa
                       "OsmoProdInduci":      expand(microbial_osmolyte_prod_rate[3],gridsize), # distribution of induci. osmolyte gene cost across taxa
                       "EnzProdConstit":      expand(microbial_enzyme_prod_rate[2],gridsize),   # distribution of consti. enzyme gene cost across taxa
                       "EnzProdInduce":       expand(microbial_enzyme_prod_rate[3],gridsize),   # distribution of induci. enzyme gene cost across taxa
                       "TaxDroughtTol":       expand(microbial_drought_tol,gridsize),           # distribution of taxon-specific drought tol.
                       'basal_death_prob':  microbial_mortality[0],                # basal death probability
                       'death_rate':        microbial_mortality[1],                # change rate of death prob. agaist mositure
                       "AE_ref":            parameters.loc["CUE_ref",1],           # Reference assimilation efficiency: 0.5
                       "AE_temp":           parameters.loc["CUE_temp",1],          # AE temperature sensitivity; default: -0.016
                       'Uptake_Maint_cost': parameters.loc['Uptake_Maint_cost',1], # constant of transporter maintenence cost
                       'C_min':             parameters.loc['C_min',1],             # C threshold of cell lysis
                       'N_min':             parameters.loc['N_min',1],             # N threshold of cell lysis
                       'P_min':             parameters.loc['P_min',1],             # P threshold of cell lysis
                       'max_size_b':        parameters.loc['max_size_b',1],        # C quota threshold for bacterial cell division
                       'max_size_f':        parameters.loc['max_size_f',1],        # C quota threshold for fungal cell division
                       'wp_fc':             parameters.loc['wp_fc',1],             # threshold below which microbes start to respond to drought
                       'wp_th':             parameters.loc['wp_th',1],             # threshold below which microbes in full swing to respond to drought
                       'alpha':             parameters.loc['alpha',1],             # factor delineating curve concavity of microbial response to drought
                       'Temp': daily_temp,                                         # temperature
                       'Psi':  daily_psi                                           # water potential
                      }

    return Data_Dictionary
