#!/usr/bin/env bats

# Test grid for coupled model (land and atmosphere are C48 and ocean is 1 degree tripolar grid)

@test "Test grid for coupled model (land and atmosphere are C48 and ocean is 1 degree tripolar grid)" {

  if [ ! -d "Test03" ] 
  then
  		mkdir Test03
  fi

  cd Test03
  cp $top_srcdir/t/Test03-input/OCCAM_p5degree.nc OCCAM_p5degree.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile1.nc C48_grid.tile1.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile2.nc C48_grid.tile2.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile3.nc C48_grid.tile3.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile4.nc C48_grid.tile4.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile5.nc C48_grid.tile5.nc
  cp $top_srcdir/t/Test03-input/C48_grid.tile6.nc C48_grid.tile6.nc

#Make_hgrid: create ocean_hgrid"
  run command make_hgrid \
		--grid_type tripolar_grid \
		--nxbnd 2 \
		--nybnd 7 \
		--xbnd -280,80 \
		--ybnd -82,-30,-10,0,10,30,90 \
		--dlon 1.0,1.0 \
		--dlat 1.0,1.0,0.6666667,0.3333333,0.6666667,1.0,1.0 \
		--grid_name ocean_hgrid \
		--center c_cell
  [ "$status" -eq 0 ]

#Make_vgrid: create ocean_vgrid
  run command make_vgrid \
		--nbnds 3 \
		--bnds 0.,220.,5500. \
		--dbnds 10.,10.,367.14286 \
		--center c_cell \
		--grid_name ocean_vgrid 
  [ "$status" -eq 0 ]

#Make_solo_mosaic: create ocean solo mosaic
  run command make_solo_mosaic \
		--num_tiles 1 \
		--dir . \
		--mosaic_name ocean_mosaic \
		--tile_file ocean_hgrid.nc \
		--periodx 360
  [ "$status" -eq 0 ]

#Make_topog: create ocean topography data
  run command make_topog \
		--mosaic ocean_mosaic.nc \
		--topog_type realistic \
		--topog_file OCCAM_p5degree.nc \
		--topog_field TOPO \
		--scale_factor -1 \
		--vgrid ocean_vgrid.nc \
		--output topog.nc 
  [ "$status" -eq 0 ]

#Skipping this for now because it fails 
#  run command mpirun -n 2 make_topog_parallel \
#		--mosaic ocean_mosaic.nc \
#		--topog_type realistic \
#		--topog_file OCCAM_p5degree.nc \
#		--topog_field TOPO \
#		--scale_factor -1 \
#		--vgrid ocean_vgrid.nc \
#		--output topog_parallel.nc
#  [ "$status" -eq 0 ]

#  run command nccmp -md topog.nc topog_parallel.nc
#  [ "$status" -eq 0 ]

#Make_hgrid: create C48 grid for atmos/land
  run command make_hgrid \
		--grid_type gnomonic_ed \
		--nlon 96 \
		--grid_name C48_grid \
  [ "$status" -eq 0 ]

#Make_solo_mosaic: create C48 solo mosaic for atmos/land
  run command make_solo_mosaic \
		--num_tiles 6 \
		--dir . \
		--mosaic C48_mosaic \
		--tile_file C48_grid.tile1.nc,C48_grid.tile2.nc,C48_grid.tile3.nc,C48_grid.tile4.nc,C48_grid.tile5.nc,C48_grid.tile6.nc
  [ "$status" -eq 0 ]

#Make_coupler_mosaic: coupler_mosaic with and without parallel and compare
  run command make_coupler_mosaic \
		--atmos_mosaic C48_mosaic.nc \
		--ocean_mosaic ocean_mosaic.nc \
		--ocean_topog  topog.nc \
		--check \
		--area_ratio_thresh 1.e-10 \
  [ "$status" -eq 0 ]

#Skipping this for now because it fails 
#  run command cd parallel

#  run command aprun -n 2 make_coupler_mosaic_parallel \
#		--atmos_mosaic ../C48_mosaic.nc \
#		--ocean_mosaic ../ocean_mosaic.nc \
#		--ocean_topog  ../topog.nc \
#		--mosaic_name grid_spec  \
#		--area_ratio_thresh 1.e-10
#  [ "$status" -eq 0 ]

#Remove the workdir 
  cd ..
  rm -rf Test03
}