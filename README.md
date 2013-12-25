# Description:

The project aims to send vmstat metrics to graphite with a shell script

# Usage:

## Setup a sample project

    git clone https://github.com/clodio/monitoring_graphite_shell_vmstat.git
    cd monitoring_graphite_shell_vmstat

## Customize the configuration

Open the file monitoring_graphite_shell_vmstat.sh and change if needed

### Change default values
- graphite server adress : 
    graphiteLocation="localhost" 
- preformationg data for graphite
    preformat="10sec.dev." 

### Comment/uncomment the metrics that you want

# Technology used

## Graphite

- Homepage: <http://graphite.wikidot.com/>
