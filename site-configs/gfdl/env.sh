# **********************************************************************
# Setup and Load the Modules
# **********************************************************************    
source /usr/local/Modules/default/init/sh
module load intel_compilers/15.0.1 mpich2/1.2.1p1 netcdf/4.2

# **********************************************************************
# Set environment variablesSetup and Load the Modules
# **********************************************************************    
LD_RUN_PATH=$LD_LIBRARY_PATH
export LD_RUN_PATH

# **********************************************************************
# Aliases
# **********************************************************************    

# **********************************************************************
# Other build configuration settings
# **********************************************************************    
