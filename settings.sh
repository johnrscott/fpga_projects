# Use this script to source the settings64.sh script from Vivado
# to set up the environment. Modify the path to Xilinx tools and
# the Vivado version depending on your installation.
#
# Run this (including the dot):
#
# . settings.sh

XILINX_PATH=$HOME/tools/Xilinx
VIVADO_VERSION=2023.2
OSS_CAD_SUITE_PATH=$HOME/tools/oss-cad-suite

. $XILINX_PATH/Vivado/$VIVADO_VERSION/settings64.sh
. $OSS_CAD_SUITE_PATH/environment
