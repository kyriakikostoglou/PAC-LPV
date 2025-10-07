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

```
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This repository provides a comprehensive MATLAB framework for simulating, estimating, and visualizing phase–amplitude coupling (PAC) using Linear Parameter-Varying autoregressive (LPV-AR) modeling.
It serves both as a reproducible research tool and as an educational implementation of the LPV-AR approach described in:

Kostoglou, K., & Müller-Putz, G. R. (2022). Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals. Frontiers in Human Neuroscience, 16, 915815. https://doi.org/10.3389/fnhum.2022.915815

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## 🧩 **Motivation**

Cross-frequency coupling (CFC) represents a key mechanism of neural communication, in which the **phase of a low-frequency oscillation** modulates the **amplitude of a higher-frequency rhythm**.  
Phase–Amplitude Coupling (PAC) is among the most widely studied forms of CFC in EEG, MEG, and LFP data.

Classical PAC metrics such as the **Modulation Index (MI)**, **Mean Vector Length (MVL)**, and **GLM-based** methods quantify coupling strength but do not model the *dynamics* of this dependency.  
The **LPV-AR framework** instead models the high-frequency amplitude envelope as the output of a **time-varying autoregressive system**, whose coefficients change smoothly as functions of the low-frequency phase.

This model-based approach provides:

- 🎯 Higher spectral specificity  
- 💪 Reduced bias outside true coupling bands  
- 🧩 Interpretability through system identification principles  

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## ⚙️ **Method Overview**

1. **Signal Generation or Acquisition**  
   Generate synthetic coupled signals with known PAC (monophasic or biphasic) or provide real EEG/LFP data.

2. **Filtering and Feature Extraction**  
   - Bandpass-filter the signal into low- and high-frequency components using `eegfilt`.  
   - Compute instantaneous phase (`angle(hilbert(x))`) and amplitude (`abs(hilbert(x))`).  
   - Remove edge samples to avoid Hilbert artifacts.

3. **LPV-AR Modeling**  
   Model the amplitude envelope as an autoregressive process with coefficients that depend on phase:

   ```
   y_t = Σ a_i(phase_t) * y_{t-i} + e_t
   ```

   where each `a_i(phase_t)` is a polynomial in `[cos(phase_t), sin(phase_t)]`.

4. **Model Selection and Regularization**  
   - Sweep over AR orders (`p`) and polynomial degrees (`n`) to minimize residual error.  
   - Use ridge regularization (`λ`) to control model complexity.  
   - Select optimal `λ` using a "U-curve" criterion balancing residual and parameter norms.

5. **Null Distribution and Modulation Index (MI)**  
   - Break the phase–amplitude relationship by shuffling the phase time series.  
   - Compare residuals between the true model and shuffled models.  
   - Compute MI as:

     ```
     MI = | log( residual_true / mean(residual_shuffled) ) |
     ```

6. **Visualization**  
   - Compute MI across grids of phase (fl) and amplitude (fh) frequencies.  
   - Display results as a 2D PAC map.
     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## 🧱 **Function Descriptions**

### **Main.m**
Main driver script that defines parameters, runs simulations, estimates PAC, and visualizes results.  
**Key parameters:**  
- `maxiters`: number of realizations  
- `snr`: signal-to-noise ratio (dB)  
- `fl`, `fh`: frequency grids for phase and amplitude  
- `ignore`: samples to remove due to Hilbert edge effects  

**Output:** averaged 2D MI map.

---

### **runall.m**
Runs PAC estimation across combinations of low and high frequencies.  
For each pair `(fl, fh)`:
- Bandpass filters the signal  
- Extracts phase and amplitude  
- Normalizes amplitude  
- Calls `pac_LPV` to compute MI  

**Output:** `MI` matrix of size `[length(fl) × length(fh)]`.

---

### **createsim1.m**
Generates a **monophasic** coupled signal:  
1. Creates narrowband low-frequency noise (`fl`)  
2. Applies a logistic amplitude modulator  
3. Modulates a high-frequency sinusoid (`fh`)  
4. Adds Gaussian noise at the specified SNR  

**Output:** simulated PAC signal `s` and sampling rate `fs`.

---

### **createsim2.m**
Generates a **biphasic** coupled signal with two amplitude peaks per phase cycle.  
Implements zero-mean modulation to produce symmetric coupling.  

**Output:** biphasic PAC signal `s` and sampling rate `fs`.

---

### **pac_LPV.m**
Core LPV-AR PAC estimator.  
**Steps:**
1. Builds scheduling variables `[cos(phase), sin(phase)]`.  
2. Searches over AR order (`p = 1–10`) and polynomial degree (`pl = 1–4`).  
3. Fits each candidate model using `LPVpol_reg`.  
4. Selects best `(p, pl)` combination by minimum residual error.  
5. Tunes `λ` using `LPVpol_reg_all` (U-curve method).  
6. Fits final model and computes MI using phase-shuffled nulls via `SIM_LPVpol`.  

**Output:** scalar modulation index (MI).

---

### **LPVpol_reg.m**
Performs **ridge-regularized LPV polynomial regression** for a given AR order, polynomial degree, and λ.  
Builds the polynomial basis of scheduling variables, constructs lagged predictors, and solves:

```
C = inv(V' * V + λ * I) * V' * y
```

No regularization is applied to the intercept term.  
Returns coefficients (`Cmat`), residuals, and residual energy.

---

### **LPVpol_reg_all.m**
Evaluates model performance across multiple λ values.  
Computes:
- `rn`: residual norm (model fit error)  
- `sn`: coefficient norm (model smoothness)  

Used to select optimal λ by minimizing the combined trade-off `log(1/rn + 1/sn)`.

---

### **SIM_LPVpol.m**
Generates a **phase-shuffled null model** to assess statistical significance.  
Uses the same coefficients (`Cmat`) as the true model but with permuted scheduling variables.  
Recomputes residual energy to obtain the null baseline.

**Output:** residual vector and residual energy.

---

### **eegfilt.m**
Implements the **EEGLAB-style zero-phase FIR bandpass filter**.  
Uses least-squares FIR design (`firls`) and forward–backward filtering (`filtfilt`) to avoid phase distortion.  
Used for extracting narrowband low- and high-frequency components.

---

## 🧪 **Example Usage**

```matlab
% Navigate to the 'code' directory and run:
Main
```

The console will print progress such as:

```
Estimating PAC... iteration 5 | low-freq 6.0 Hz | high-freq 40.0 Hz
```
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 📄 **License**

Released under the **MIT License**.  
If you use this code, please cite this repository and the following paper:

> **Kostoglou, K., & Müller-Putz, G. R. (2022).**  
> *Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals.*  
> *Frontiers in Human Neuroscience, 16, 915815.*  
> [https://doi.org/10.3389/fnhum.2022.915815](https://doi.org/10.3389/fnhum.2022.915815)
