# LPV-Based Phase–Amplitude Coupling Estimation

This repository implements a **Linear Parameter-Varying (LPV)** modeling framework for estimating **Phase–Amplitude Coupling (PAC)** between neural oscillations.  
It simulates coupled signals, applies ridge-regularized LPV regression, and visualizes the resulting modulation index (MI) across phase–amplitude frequency pairs.

---

## 📂 Structure
/ [root]
├── code
│   ├── Main.m                 # Main script (entry point)
│   ├── runall.m               # Runs PAC estimation across frequency grid
│   ├── createsim1.m           # Monophasic coupling simulation
│   ├── createsim2.m           # Biphasic coupling simulation
│   ├── pac_LPV.m              # LPV-based PAC estimator
│   ├── LPVpol_reg.m           # Single regularized LPV regression
│   ├── LPVpol_reg_all.m       # Multi-λ model evaluation
│   ├── SIM_LPVpol.m           # Residual test with fixed coefficients
│   └── eegfilt.m              # FIR filter (EEGLAB version)
├── README.md
└── LICENSE


