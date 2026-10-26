[README.md](https://github.com/user-attachments/files/33973264/README.md)
# Globalization and Human Capital Accumulation

MATLAB code for a dynamic multi-country, multi-sector **Eaton–Kortum trade model with endogenous human capital accumulation**. The model is calibrated to 2015 data for 42 countries and 158 manufacturing industries. The code solves the static general equilibrium each period and simulates the transition of skilled labor and physical capital to the steady state. It is used for counterfactuals on trade costs and education policy.

**Paper:** [Globalization and Human Capital Accumulation](paper.pdf), Roman Solntsev, University of Michigan (third-year PhD paper, 2025)

---

## The question

Developing countries now hold a growing share of the world's college-educated workers. Does international trade drive this? Trade-induced specialization changes skill premia, and skill premia change education decisions. This project quantifies how strong that feedback loop is.

## Model

- **N countries, J tradable sectors.** Production uses skilled labor, unskilled labor and capital. Sectors differ in skill intensity (α_j) and capital intensity.
- **Trade** follows Eaton and Kortum (2002). Bilateral trade shares depend on sectoral productivities T, unit costs c and iceberg trade costs d, with trade elasticity θ = 8.28.
- **Education choice.** Families choose college enrollment based on the skill premium and a country-specific education cost aᵢ. With Type-I extreme value taste shocks, enrollment is

  $$E_n = \frac{1}{1 + \left(a_n \, w^L_n / w^H_n\right)^{1/\chi}}$$

- **Dynamics.** Skilled labor follows $H_{t+1} = (1-\varepsilon)H_t + \varepsilon N E_t$ with ε = 0.05. Physical capital follows a Solow rule, $K_{t+1} = sY_t + (1-\delta)K_t$.

The mechanism: trade moves countries toward their comparative-advantage sectors. That shifts relative demand for skilled labor, which changes the skill premium, enrollment and, over time, each country's stock of human capital.

## Algorithm

**1. Static equilibrium (`Search.m` → `Equilib.m`).** Given endowments (H, L, K), the code finds factor prices (w_L, w_H, r) that clear all factor markets:

1. Compute unit costs $c^j_n = \left((w^H_n)^{\alpha_j}(w^L_n)^{1-\alpha_j}\right)^{\beta_j} r_n^{1-\beta_j}$.
2. Compute multilateral resistance $\Phi^j_n = \sum_i T^j_i (c^j_i d_{ni})^{-\theta}$, sectoral prices, CES final demand and bilateral trade shares $\pi^j_{ni}$.
3. Compute factor demand implied by world spending on each country's output, and the resulting excess demand for each factor.
4. Update prices with a damped tâtonnement step, `w ← w · (1 − 0.2 · excess / endowment)`. Renormalize to a numeraire and iterate until excess demand is below tolerance.

**2. Transition (`main.m`).** Each period: solve the static equilibrium, update enrollment and skilled labor from the new skill premia, and update capital from savings. The loop runs until countries reach their steady state.

## Repository structure

| File | Role |
|---|---|
| `main.m` | Entry point: loads data, sets parameters, solves the initial equilibrium and runs the transition loop |
| `Search.m` | Outer equilibrium solver: iterates on factor prices until markets clear |
| `Equilib.m` | One equilibrium step: costs, trade shares, factor demand, excess demand, price update |
| `F_Phi_j.m` | Multilateral resistance term Φ for tradable sectors |
| `F_Phi_J1.m` | Φ for the non-tradable sector (currently switched off) |
| `Prices.m` | Eaton–Kortum sectoral price index |
| `demand.m` | CES sectoral final demand |
| `Phi_j.m`, `F_Ag_price.m` | Helper functions for a version with time and a services sector (not called by `main.m`) |

## Data

All inputs are model-ready CSVs for 2015. Rows index the 42 countries in a fixed order, and columns index the 158 NAICS manufacturing industries.

| File | Dimensions | Content |
|---|---|---|
| `2015_tech.csv` | 42 × 158 | Sectoral productivities T (estimated from trade flows) |
| `2015trade_cost_matrix.csv` | 42 × 42 | Bilateral iceberg trade costs d |
| `2015naics.csv` | 158 × 3 | NAICS code, skill intensity α_j, labor share β_j |
| `2015_omega.csv` | 42 × 158 | Sectoral expenditure weights (averaged across countries in `main.m`) |
| `2015_popul.csv` | 42 × 2 | Tertiary-educated share (%), labor force |
| `2015_wage.csv`, `2015_wage_h.csv`, `2015_r.csv` | 42 × 1 | Starting values for unskilled wage, skilled wage, rental rate |
| `2015_K.csv` | 42 × 1 | Physical capital stock |
| `2015_a.csv` | 42 × 1 | Calibrated education cost aₙ |
| `2015_d.csv`, `2015_s.csv` | 42 × 1 | Depreciation rate, savings rate |
| `2015_rgdp.csv`, `Normalization.csv` | 42 × 1 | Real GDP and the saved scaling factor from model output to GDP |
| `2015_Z.csv` | 158 × 2 | Sector-level auxiliary data (not used by `main.m`) |

**Sources:** UN COMTRADE (bilateral trade), UNIDO INDSTAT (manufacturing output), Penn World Table 10.0 (wages), Montenegro and Patrinos (2023) (returns to schooling), Barro–Lee (educational attainment).

## How to run

Requires MATLAB R2019a or later (for `readmatrix`). No toolboxes are needed.

1. Clone or download the repository and set it as MATLAB's working folder.
2. Run `main.m`.

After the loop finishes, the steady-state allocation is in the workspace: skilled and unskilled labor (`H`, `L`), capital (`K`), factor prices (`w_h`, `w_l`, `r`) and output (`Y`).

## Key results (from the paper)

- **Theory.** If countries have similar technologies, trade affects only the speed of convergence, not the steady state. If Ricardian comparative advantage dominates, lower trade costs widen the gap in human capital between countries.
- **Steady state.** The college-educated share of the labor force rises from 16.3% (2015) to 24.3% in the steady state.
- **30% increase in trade costs.** Enrollment changes by only about 0.04 percentage points on average. Country-level changes range from about −2 pp (Switzerland) to +1.4 pp (South Korea) and track sectoral reallocation closely (R² = 0.91).
- **China counterfactuals.** Freezing China's human capital, or raising its enrollment to 60%, has small spillovers on other countries (under 0.3 pp even for Korea, Japan and Thailand).

Overall, trade plays a modest role in the global distribution of human capital, because its effect on skill premia is limited and enrollment responds only moderately to returns.

## Citation

```
Solntsev, Roman (2025). "Globalization and Human Capital Accumulation."
Third-year PhD paper, University of Michigan.
```

## Contact

Roman Solntsev · solntsev@umich.edu · [rsolntsev.github.io](https://rsolntsev.github.io)
