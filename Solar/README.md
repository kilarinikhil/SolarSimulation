# DESCRIPTION
This helps to get a hands on experience with SimuLink.<br> 
We normally choose the blocks required for simulation from library, but here to simulate a dynamic solar block it is herculean. <br> 

So I wrote a MATLAB code through which it automtically generates the simulink model. <br> 
Go through the basics_readme before going through the simulations for better understanding. <br> 

The total work is divided into three parts. sample.m, bypassdiode.m and finally partial_shading.m <br> 

## Sample.m
Input Parameters:
- Number of solar cells in series.

## Bypassdiode.m
Input Parameters:
- Number of solar cells in series.
- Number of by pass diodes

### Caution:
Make sure that the number of bypass diodes equally balances the number of cells connected in series.

## Partial_shading.m
Input Parameters:
- Number of solar cells in series.
- Number of by pass diodes.
- Number of partial shaded cells.
- Minimum Irradiance.
- Maximum Irradiance.

**Please fork or star if you like the work.**
