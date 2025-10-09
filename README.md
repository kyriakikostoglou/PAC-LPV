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

> **Kostoglou, K., & Müller-Putz, G. R. (2022).**  
> *Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals.*  
> *Frontiers in Human Neuroscience, 16, 915815.*  
> [https://doi.org/10.3389/fnhum.2022.915815](https://doi.org/10.3389/fnhum.2022.915815)
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

<img width="592" height="266" alt="image" src="https://github.com/user-attachments/assets/03c9e043-e069-4d49-8713-fa4253038041" />

<h5>Copied from Kostoglou, K., & Müller-Putz, G. R. (2022) under CC-BY license.</h5> 
     
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

<img width="444" height="570" alt="image" src="https://github.com/user-attachments/assets/47aad605-5f4a-4539-9851-0e9783146d77" />

<h5>Copied from Kostoglou, K., & Müller-Putz, G. R. (2022) under CC-BY license.</h5>

---

### **createsim2.m**
Generates a **biphasic** coupled signal with two amplitude peaks per phase cycle.  
Implements zero-mean modulation to produce symmetric coupling.  

**Output:** biphasic PAC signal `s` and sampling rate `fs`.

<img width="475" height="568" alt="image" src="https://github.com/user-attachments/assets/84d22b8f-ee69-4fd1-976e-245adbe5d49e" />

<h5>Copied from Kostoglou, K., & Müller-Putz, G. R. (2022) under CC-BY license.</h5>

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
7. 
**Output:** scalar modulation index (MI).

![fnhum-16-915815-g003](https://github.com/user-attachments/assets/31e006e6-50c8-4d0c-8a53-e5c49bc4c279)
<h5>Two step model order selection procedure for one representative realization of Eq. 31 and simulation set I. (A) The top panel depicts the MSE obtained during step 1 for different p and q values using a regularization parameter of λ = 10 as an initial value. The bottom panel depicts the U-curve from step 2, using the model order that achieved the smallest MSE [i.e., (p,q) = (10,2)] at step 1 (i.e., top panel). The regularization parameter that corresponds to the minimum of the U-curve was selected as optimal (i.e., λ = 1). (B) Similar as (A), however, the initial regularization parameter at step 1 was set to λ = 0.01. Copied from Kostoglou, K., & Müller-Putz, G. R. (2022) under CC-BY license.</h5>


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
Estimating PAC... realization 1 | low-freq 6.0 Hz | high-freq 40.0 Hz
```
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## 📚 **Reference** (please cite the following work, thank you!)

> **Kostoglou, K., & Müller-Putz, G. R. (2022).**  
> *Using linear parameter varying autoregressive models to measure cross frequency couplings in EEG signals.*  
> *Frontiers in Human Neuroscience, 16, 915815.*  
> [https://doi.org/10.3389/fnhum.2022.915815](https://doi.org/10.3389/fnhum.2022.915815)
