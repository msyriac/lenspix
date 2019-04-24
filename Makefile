
F90C     = mpif90

# CHANGE THESE
export HEALPIX=/gpfs01/astro/workarea/msyriac/software/Healpix_3.31
export CFITSIO=$(CFITSIO_DIR)

healpix = $(HEALPIX)
LAPACKL = -lmpi -lhealpix -fopenmp 
FFLAGS = -O3 -march=native -cpp -DMPIPIX -DMPI -DGFORTRAN -fno-second-underscore

cfitsio ?= $(CFITSIO)
F90FLAGS = $(FFLAGS) -I$(healpix)/include -I/usr/include -L/usr/lib -L$(cfitsio)/lib -L$(healpix)/lib $(LAPACKL) -lcfitsio

OBJFILES= toms760.o inifile.o utils.o spin_alm_tools.o HealpixObj.o HealpixVis.o

LENSPIX = $(OBJFILES) SimLens.o

default: simlens
all: simlens recon

spin_alm_tools.o:  utils.o toms760.o
HealpixObj.o: spin_alm_tools.o
HealpixVis.o: HealpixObj.o
SimLens.o: HealpixVis.o inifile.o

.f.o:
	f77 $(F90FLAGS) -c $<

%.o: %.f90
	$(F90C) $(F90FLAGS) -c $*.f90

%.o: %.F90
	$(F90C) $(F90FLAGS) -c $*.F90


simlens: $(LENSPIX) 	
	$(F90C) -o simlens $(LENSPIX) $(F90FLAGS) $(LINKFLAGS)

recon: $(OBJFILES) LensReconExample.o
	$(F90C) -o recon $(OBJFILES) LensReconExample.o $(F90FLAGS) $(LINKFLAGS)

clean:
	rm -f *.o* *.e* *.mod *.d *.pc *.obj core* *.il
