#!/bin/bash 
#-------------------------------------------------------
#  Part 1: Check for and handle command-line arguments
#-------------------------------------------------------
TIME_WARP=1
JUST_MAKE="no"
for ARGI; do
    if [ "${ARGI}" = "--help" -o "${ARGI}" = "-h" ] ; then
	printf "%s [SWITCHES] [time_warp]   \n" $0
	printf "  --just_make, -j    \n" 
	printf "  --help, -h         \n" 
	exit 0;
    elif [ "${ARGI//[^0-9]/}" = "$ARGI" -a "$TIME_WARP" = 1 ]; then 
        TIME_WARP=$ARGI
    elif [ "${ARGI}" = "--just_build" -o "${ARGI}" = "-j" ] ; then
	JUST_MAKE="yes"
    else 
	printf "Bad Argument: %s \n" $ARGI
	exit 0
    fi
done

#-------------------------------------------------------
#  Part 2: Create the .moos and .bhv files. 
#-------------------------------------------------------
VNAME1="Archie"    # The first  vehicle community
START_POS1="0,0"  
SHORE_LISTEN="9300"
VNAME2="Betty"    # The second  vehicle community
START_POS2="0,0"  

nsplug meta_vehicle_one.moos targ_Archie.moos -f WARP=$TIME_WARP  \
   VNAME=$VNAME1      START_POS=$START_POS1                  \
   VPORT="9001"       SHARE_LISTEN="9301"                    \
   VTYPE=UUV          SHORE_LISTEN=$SHORE_LISTEN             \
   MASTER="true"
nsplug meta_vehicle_two.moos targ_Betty.moos -f WARP=$TIME_WARP  \
   VNAME=$VNAME2      START_POS=$START_POS2                  \
   VPORT="9002"       SHARE_LISTEN="9302"                    \
   VTYPE=UUV          SHORE_LISTEN=$SHORE_LISTEN             \
   MASTER="false"

nsplug meta_vehicle.bhv targ_Archie.bhv -f VNAME=$VNAME1      \
    START_POS=$START_POS1 
nsplug meta_vehicle.bhv targ_Betty.bhv -f VNAME=$VNAME1      \
    START_POS=$START_POS2 

nsplug meta_shoreside.moos targ_shoreside.moos -f WARP=$TIME_WARP \
   VNAME="shoreside"  SHARE_LISTEN=$SHORE_LISTEN                  \
   VPORT="9000"       

if [ ${JUST_MAKE} = "yes" ] ; then
    exit 0
fi

#-------------------------------------------------------
#  Part 3: Launch the processes
#-------------------------------------------------------
printf "Launching $VNAME1 MOOS Community (WARP=%s) \n" $TIME_WARP
pAntler targ_Archie.moos >& /dev/null &
sleep .25
printf "Launching $VNAME2 MOOS Community (WARP=%s) \n" $TIME_WARP
pAntler targ_Betty.moos >& /dev/null &
sleep .25
printf "Launching $SNAME MOOS Community (WARP=%s) \n"  $TIME_WARP
pAntler targ_shoreside.moos >& /dev/null &
printf "Done \n"

uMAC targ_shoreside.moos

printf "Killing all processes ... \n"
kill %1 %2 %3
printf "Done killing processes.   \n"


