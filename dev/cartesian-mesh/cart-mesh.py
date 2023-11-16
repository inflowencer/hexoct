import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys

# No of cells in each direction
Nx = 2
Ny = 3
Nz = 3

dx = 1

#* Points
Px = Nx + 1
Py = Ny + 1
Pz = Nz + 1

Ptotal = Px * Py * Pz

# Initialize array of point coordinates
points = np.empty((Ptotal, 3))

# Fill points array with coordinates based on dx
p = 0
for x in range(Px):
    for z in range(Pz):
        for y in range(Py):
            points[p, 0] = x * dx
            points[p, 1] = y * dx
            points[p, 2] = z * dx
            p += 1

#* Cells
# Initialize cell array
Ntotal = Nx * Ny * Nz
cells = np.empty((Ntotal, 8), dtype=int)

# Calculate node deltas
AC = EG = zjump = Ny + 1
AE = (Ny + 1) * (Nz + 1)
xjump = AE - 1


def cellNodes(A):
    """Calculates cell nodes for a cube according to:
        [xlo, ylo, zlo]
        [xlo, yhi, zlo]
        [xlo, ylo, zhi]
        [xlo, yhi, zhi]
        [xhi, ylo, zlo]
        [xhi, yhi, zlo]
        [xhi, ylo, zhi]
        [xhi, yhi, zhi]"""

    B = A + 1
    C = A + AC
    D = C + 1
    E = A + AE
    F = E + 1
    G = E + EG
    H = G + 1
    return B, C, D, E, F, G, H

# Initialize first node and tmp node
A0 = 1
A = A0

# Initialize cell counters
zcounter = 1
xcounter = 1
# Fill points array with coordinates based on dx
for c in range(Ntotal):
    B, C, D, E, F, G, H = cellNodes(A)
    cells[c][0] = A
    cells[c][1] = B
    cells[c][2] = C
    cells[c][3] = D
    cells[c][4] = E
    cells[c][5] = F
    cells[c][6] = G
    cells[c][7] = H

    if zcounter % Nz == 0 and not xcounter % (Ny * Nz) == 0:
        print("Loop 1, c = ", c+1)
        A0 += zjump - 2
        A = A0
        zcounter = 0
    elif xcounter % (Ny * Nz) == 0:
        print("Loop 2, c = ", c+1)
        print("H = ", H)
        print("AE = ", AE)
        A0 = H - (AE - 1)
        A = A0
        xcounter = 0
    else:
        A0 += 1
        A = A0

    zcounter += 1
    xcounter += 1