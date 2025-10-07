# 🧠 LPV-Based Phase–Amplitude Coupling (PAC) Estimation

This repository implements a **Linear Parameter-Varying (LPV)** modeling framework for estimating **Phase–Amplitude Coupling (PAC)** between neural oscillations.  
It simulates coupled signals, applies ridge-regularized LPV regression, and visualizes the resulting modulation index (MI) across phase–amplitude frequency pairs.

---

## 📁 Structure

```text
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This repository provides a comprehensive MATLAB framework for simulating, estimating, and visualizing phase–amplitude coupling (PAC) using Linear Parameter-Varying autoregressive (LPV-AR) modeling.
It serves both as a reproducible research tool and as an educational implementation of the LPV-AR approach described in:

Kostoglou, K., & Müller-Putz, G. R. (2022). Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals. Frontiers in Human Neuroscience, 16, 915815. https://doi.org/10.3389/fnhum.2022.915815

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🧩 Motivation and Background
Cross-frequency coupling (CFC) — particularly phase–amplitude coupling (PAC) — describes a fundamental mechanism of neural coordination in which the phase of a slow oscillation modulates the amplitude of a faster rhythm.
PAC has been widely studied in EEG, MEG, and LFP data to understand hierarchical communication across spatial and temporal scales in the brain. Conventional PAC metrics, such as: the Modulation Index (MI) by Tort et al., the Mean Vector Length (MVL), or General Linear Model (GLM) based methods, quantify the strength of coupling but do not model the dynamics of the relationship itself. The LPV-AR framework extends these traditional approaches by explicitly modeling the amplitude envelope of the high-frequency signal as an output of a time-varying autoregressive process, whose coefficients evolve smoothly as a function of the low-frequency phase. This parameter-varying structure enables the model to capture nonlinear dependencies and time-varying interactions, offering: higher spectral specificity, reduced bias outside true coupling bands, and interpretability through system identification principles.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

⚙️ Method Overview
1. Signal Generation or Acquisition: Generate synthetic coupled signals with known PAC (monophasic or biphasic) or provide real EEG/LFP data.

2. Filtering and Feature Extraction:
    - Bandpass-filter the signal into low- and high-frequency components using eegfilt.
    - Compute instantaneous phase (angle(hilbert(x))) and amplitude (abs(hilbert(x))).
    - Remove edge samples to avoid Hilbert artifacts.

3. LPV-AR Modeling: Model the amplitude envelope as an autoregressive process with coefficients that depend on phase y_t = Σ a_i(phase_t) * y_{t-i} + e_t where each a_i(phase_t) is a polynomial in [cos(phase_t), sin(phase_t)].

4. Model Selection and Regularization:
    -Sweep over AR orders (p) and polynomial degrees (n) to minimize residual error.
    -Use ridge regularization (λ) to control model complexity.
    -Select optimal λ using a "U-curve" criterion balancing residual and parameter norms.

5. Null Distribution and Modulation Index (MI)
  - Break the phase–amplitude relationship by shuffling the phase time series.
  - Compare residuals between the true model and shuffled models.
  - Compute MI as: MI = | log( residual_true / mean(residual_shuffled) ) |

6. Visualization
  - Compute MI across grids of phase (fl) and amplitude (fh) frequencies.
  - Display results as a 2D PAC map (i.e., commodulogram).

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




If you use this code, please cite this repository and the following paper:

Kostoglou, K., & Müller-Putz, G. R. (2022).
Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals.
Frontiers in Human Neuroscience, 16, 915815.
https://doi.org/10.3389/fnhum.2022.915815
