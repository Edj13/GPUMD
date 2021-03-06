/*
    Copyright 2017 Zheyong Fan, Ville Vierimaa, Mikko Ervasti, and Ari Harju
    This file is part of GPUMD.
    GPUMD is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    GPUMD is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with GPUMD.  If not, see <http://www.gnu.org/licenses/>.
*/


#include "common.cuh"
#include "ensemble.cuh"
#include "ensemble_nve.cuh"
#include "ensemble_ber.cuh"
#include "ensemble_nhc.cuh"
#include "integrate.cuh"
#include "force.cuh"



Integrate::Integrate(void)
{
    ensemble = NULL;
}



Integrate::~Integrate(void)
{
    // nothing
}



void Integrate::finalize(void)
{
    delete ensemble;
    ensemble = NULL;
}


void Integrate::initialize(Parameters *para, CPU_Data *cpu_data)
{
    // determine the integrator
    switch (type)
    {
        case 0: 
            ensemble = new Ensemble_NVE(type);
            break;
        case 1: 
            ensemble = new Ensemble_BER
            (type, temperature, temperature_coupling);
            break;
        case 2: 
            ensemble = new Ensemble_BER
            (
                type, temperature, temperature_coupling, pressure_x, 
                pressure_y, pressure_z, pressure_coupling
            );
            break;
        case 3: 
            ensemble = new Ensemble_NHC            
            (
                type, para->N, temperature, temperature_coupling, 
                para->time_step
            );
            break;
        case 4: 
            ensemble = new Ensemble_NHC
            (
                type, source, sink, cpu_data->group_size[source], 
                cpu_data->group_size[sink], temperature, temperature_coupling, 
                delta_temperature, para->time_step
            );
            break;
        default: 
            printf("Illegal integrator!\n");
            break;
    }
}




void Integrate::compute
(Parameters *para, CPU_Data *cpu_data, GPU_Data *gpu_data, Force *force)
{
    ensemble->compute(para, cpu_data, gpu_data, force);
}




