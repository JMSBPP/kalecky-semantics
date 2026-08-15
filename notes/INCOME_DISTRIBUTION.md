

>[CHECKPOINT](~/learning/post-keynesian/refs/blecker-setterfield-2019-heterodox-macroeconomics.pdf) 

> PG 204

## FUNCTIONAL_INCOME_DISTRIBUTION:

\[
	\begin{aligned}
		\psi_{(\cdot, \cdot)} (Y)\, (\text{mechanism}): \Pi \, (\text{or}) \, W \times \Pi \, (\text{or}) \, W \, \xrightarrow[\text{mechanism}]  \, (\frac{\Pi}{Y} , \frac{W}{Y}) \, (\text{or}) \, \frac{\Pi}{Y}\,(\text{or})\, \frac{W}{Y} 
	\end{aligned}
\]

> We are including a third orthogolal summand on wages and is the informal sector W_{L_I}

\[
	\begin{aligned}
		\begin{bmatrix} \frac{W_L}{Y} & \psi_{(\Pi_{L_M}, L)} & \psi_{(\Pi_K, L) } & \psi_{(\Pi_F, L)} \\
			\frac{W_{M_L}}{Y} & \psi_{(\Pi_{L_M}, L)} & \psi_{(\Pi_K, L) } & \psi_{(\Pi_F, L)} \\
			\cdots\\
			\frac{W_L}{Y} & \psi_{(\Pi_{L_M}, L)} & \psi_{(\Pi_K, L) } & \psi_{(\Pi_F, L)}  \\
			\frac{W_L}{Y} & \psi_{(\Pi_{L_M}, L)} & \psi_{(\Pi_K, L) } & \psi_{(\Pi_F, L)}
		\end{bmatrix} \cdot \begin{bmatrix} L \\ L_M \\ \cdots \\ K \\ F\end{bmatrix} \equiv P \cdot Y \equiv \min \{P\cdot Y_K, \mathbb{E}^{\mathbb{F}} [DA]\}
	\end{aligned}
\]

We have :

\[
	\begin{aligned}
		\psi_{(W,W)} \, (Y) \, &\equiv \, \psi_{(W_{L},W_{L})} \, \oplus \, \psi_{(W_{M_L},W_{L})} \, \oplus \, \psi_{(W_{M_L},W_{M_L})} \, \oplus \, \psi_{(W_{L},W_{M_L})} \\
		\psi_{(W, \Pi)} \,(Y) \, &\equiv \, \psi_{(W_L, \Pi_K)} \, \oplus \, \psi_{(W_{M_L}, \Pi_K)} \, \oplus \, \psi_{(W_{L}, \Pi_F)} \, \oplus \, \psi_{(W_{M_L}, \Pi_F)}
	\end{aligned}
\]

\[
	\begin{aligned}
		\psi_{(W,W)} \, (Y) + \psi_{(W, \Pi)} \,(Y) \equiv 1 \\
		\\
		\psi_{(\Pi,W)} \, (Y) + \psi_{(\Pi, \Pi)} \,(Y) \equiv 1\\
		\\
		\psi_{(W, \Pi)} \,(Y) < \psi_{(\Pi, \Pi)} \,(Y) \wedge \psi_{(W, W)} \,(Y) > \psi_{(\Pi, W)} \,(Y)
	\end{aligned}
\]

> TODO: We need to idenify all the forms of those mechanism in Colonnbia, emaingnthey have 'legal' names. Example a progressinve tax structure can add to \psi_{W_{M_L}, W_L} and so on This is not a lean work but later once the \psi objetc is formalized is other agents work

> Distribution Mechanisms seems to be intuitiviely, transfers, subsidiies, taxes, credits, etc
---> indirect, direct
> Of importacnce are the ratios \(L/L_M , K/F\) associted with metrics like efficiency \(1 / (L / L_M)\)



\[
	\begin{aligned}
    	\begin{bmatrix}
			m        \\ 
			\epsilon_{P/W} \\
			s \\
			K \\
			L , L/N,   \\
			\mathbb{E}^{\mathbb{F}} \, [DA] \\
			\mathbb{E}^{\mathbb{F}} \, [W] \\
			\mathbb{E}^{\mathbb{H}} \, [W] \\
		\end{bmatrix} \,
		\rightarrow \, 
		\begin{bmatrix}
			P \\
			(\frac{\Pi}{Y} , \frac{W}{Y}) \\
			Y_K \\
			\frac{\Delta P}{P}
		\end{bmatrix} \, \to \, 
		\begin{bmatrix}
			Y \equiv \min \{Y_K, \mathbb{E}^{\mathbb{F}} \, [DA]\} \\
			\frac{W}{P} \\
	        \frac{\Pi}{P} \\ 
			\frac{Y}{Y_K} \\
			\frac{1}{L/Y} \\
			\frac{1}{K/Y_K}
		\end{bmatrix} \, 
		\to \,
		\begin{bmatrix} 
			S \\
			\Delta K \equiv I \equiv I^d (\cdot)
		\end{bmatrix} \, \to \, 
		\begin{bmatrix}
			\frac{\Delta Y}{Y}
		\end{bmatrix}
		
	\end{aligned}
\]




# TYPES

GrowthRate
CommonGrowthRate(GrowthRate,GrowthRate) -> GrowthRate

ResponseMultiplier(GrowthRate, Conflict) 


                               /
                          ---- \ 
                        /
                       /                    ---
       --- Effect(Responder,Perturband)   /
     /                         \--------- 
	/                                     \ ---- DistributionalEffect(. , DistrbutionRate)


?  	  
    \                     -- ExpectationsConflict(Expectation, . )
  	 \                / 
	  -- Conflict( ...,...)
	  


Gap(ExpectationVar, RealizedVar)

Effect {
	Multilplier(GrowthRate) -> Number
}
Indexation (GrowthRate, GrowthRate) 

	  
Elasticity (Effect, ...)


src/Kalecky/
└── types
    ├── Prices
    │   └── Wage.hs
    └── Units

- `Conflict` es una estructura algebraica general de diferencia:
- `ExpectationsConflict` es un refinamiento semántico, subtipo o constructor especializado de `Conflict`

> Como decidir cual es mas apropiado ?

- `ResponseMultiplier` debe codificar explícitamente “respuesta de qué a perturbación de qué”:

```haskell
data ResponseMultiplier responder perturband =
  ResponseMultiplier
    (Effect responder perturband)
    Number
```

- 

```haskell
data Indexation target reference =
  Indexation
    { indexationEffect ::
        Effect (GrowthRate target) (GrowthRate reference)
    , indexationRate :: Number
    }
```


- `DistributionalEffect` refinamiento de `Effect` **cuando el perturbando es una variable distributiva**.
- `Elasticity` derivada de `Effect`:

```haskell
data Elasticity responder perturband =
  Elasticity
    { effect ::
        Effect responder perturband
    , normalization ::
        perturband / responder
    }

Effect(responder, perturband)
│
├── ResponseMultiplier(...)
│
├── Elasticity(...)
│
└── DistributionalEffect(...)
      │
      └── NetDistributionalEffect

Conflict(a,b)
│
└── ExpectationsConflict(
      Expectation agentA x,
      Expectation agentB x
)


GrowthRate(x)
│
└── CommonGrowthRate(x,y)

Indexation(target, reference)
    └── Effect(
          GrowthRate target,
          GrowthRate reference
        )

NominalWageGrowth :: GrowthRate (NominalWage:: NominalVar(PriceIndex))
  =
    ResponseMultiplier<
        nominalWageGrowth :: GrowthRate (nominalWage:: NominalVar(PriceIndex)),
        householdRealWageExpectationGap :: Gap (Expectation (household :: Measure, realWage :: ?? )))
      >
      * householdRealWageExpectationGap :: Gap (Expectation (household :: Measure, realWage :: ?? )))

  + ResponseMultiplier<
        nominalWageGrowth :: GrowthRate (nominalWage:: NominalVar(PriceIndex)),
        laborProductivityGrowth :: GrowthRate (laborProductivity :: ?? )
      > 
      * laborProductivityGrowth :: GrowthRate (laborProductivity :: ?? )

  + Indexation<
        nominalWage :: NominalVar(PriceIndex),
        PriceLevel :: PriceIndex
      >
      * inflationRate :: GrowthRate (PriceIndex)
```

- `Gap` es algebraico
- `Conflict` es semántico, **subtipo/newtype especializado** sobre `Gap`


## 1. `Gap` como estructura algebraica básica

Si ambos lados deben pertenecer al mismo espacio:

```haskell
data Gap x =
  Gap
    { lhs :: x
    , rhs :: x
    }
```

con interpretación:

\[
\operatorname{evalGap}(\operatorname{Gap}(x_1,x_2))
= x_1-x_2.
\]

Esto requiere que (x) admita resta.

Ejemplos:

[
\operatorname{Gap}\left(
\mathbb E^H[W/P],,W/P
\right)
]

[
\operatorname{Gap}\left(
Y,,Y_K
\right)
]

[
\operatorname{Gap}\left(
\pi,\pi^{target}
\right).
]

No todos esos gaps son conflictos.


# 2. `Conflict`: wrapper semántico sobre `Gap`

```haskell
data Conflict kind x =
  Conflict (Gap x)
```

y:

```haskell
data ConflictKind
  = Expectations
  | Distributional
  | Bargaining
  | Pricing
```

O, si quieres máxima seguridad de tipos:

```haskell
newtype ExpectationsConflict x =
  ExpectationsConflict (Gap x)
```

```haskell
newtype DistributionalConflict x =
  DistributionalConflict (Gap x)
```

### ¿Por qué prefiero esto?

Porque:

[
\texttt{Gap}
]

dice **qué operación algebraica existe**, mientras:

[
\texttt{ExpectationsConflict}
]

dice **qué significa económicamente esa diferencia**.

Por ejemplo:

```haskell
Gap RealWage
```

puede ser:

[
\mathbb E^H[W/P]-W/P
]

sin que haya dos agentes en conflicto.

Pero:

[
\mathbb E^H[W/P]-\mathbb E^F[W/P]
]

sí puede refinarse a:

```haskell
ExpectationsConflict RealWage
```

Por tanto:

```text
Gap
└── Conflict
    ├── ExpectationsConflict
    ├── DistributionalConflict
    └── BargainingConflict
```

es la jerarquía que usaría.

---

# 3. `Effect` debe ser el objeto fundamental

Aquí también simplificaría.

Si conceptualmente:

[
\operatorname{Effect}(Y,X)
\equiv
\frac{\partial Y}{\partial X},
]

entonces:

```haskell
data Effect responder perturband =
  Effect Number
```

o mejor:

```haskell
newtype Effect responder perturband =
  Effect Number
```

si Plank tiene algo parecido a `newtype`.

Entonces:

```haskell
ResponseMultiplier
```

no necesita guardar un `Effect` **y además** otro `Number`, porque el efecto ya es el número.

Mejor:

```haskell
newtype ResponseMultiplier responder perturband =
  ResponseMultiplier
    (Effect responder perturband)
```

Interpretación:

[
\operatorname{ResponseMultiplier}(Y,X)
:
\frac{\partial Y}{\partial X}.
]

Por ejemplo:

```haskell
ResponseMultiplier
  NominalWageGrowth
  HouseholdRealWageExpectationGap
```

corresponde a:

[
\frac{
\partial(\Delta W/W)
}{
\partial\left(
\mathbb E^H[W/P]-W/P
\right)
}.
]

---

# 4. `DistributionalEffect`

Sí debe ser un refinamiento de `Effect`.

Pero yo no pondría `DistributionRate` como un campo adicional necesariamente. Haría que el **tipo del perturbando** ya codifique que es distributivo:

```haskell
newtype DistributionalEffect responder distributionVariable =
  DistributionalEffect
    (Effect responder distributionVariable)
```

Por ejemplo:

```haskell
DistributionalEffect
  SavingsRate
  ProfitShare
```

representa:

[
\frac{\partial(S/Y)}
{\partial(\Pi/Y)}.
]

Y si el resultado evaluado es:

[
s_\Pi-s_W,
]

eso puede ser:

```haskell
newtype NetEffect x =
  NetEffect x
```

y específicamente:

```haskell
newtype NetDistributionalEffect x =
  NetDistributionalEffect x
```

Así distingues:

[
\texttt{DistributionalEffect}
]

= operador,

de

[
\texttt{NetDistributionalEffect}
]

= valor resultante de evaluar/componer el operador.

Esa separación me parece importante.

---

# 5. `Elasticity`

Tu idea está bien:

[
\varepsilon_{Y,X}
=================

\frac{\partial Y}{\partial X}
\frac{X}{Y}.
]

Pero:

```haskell
perturband / responder
```

no debería aparecer literalmente como tipo Haskell.

Yo haría:

```haskell
data Elasticity responder perturband =
  Elasticity
    { effect ::
        Effect responder perturband
    , normalization ::
        Normalization perturband responder
    }
```

con:

```haskell
data Normalization numerator denominator =
  Normalization Number
```

Entonces conceptualmente:

```haskell
Normalization X Y
```

representa:

[
\frac{X}{Y}.
]

Incluso puedes derivar:

```haskell
elasticity
  :: Effect y x
  -> x
  -> y
  -> Elasticity y x
```

en vez de almacenar redundancias.

---

# 6. `Indexation`

Tu definición está cerca, pero vuelve a haber redundancia:

```haskell
data Indexation target reference =
  Indexation
    { indexationEffect ::
        Effect (GrowthRate target) (GrowthRate reference)
    , indexationRate :: Number
    }
```

Si `indexationEffect` ya contiene el escalar:

[
\frac{
\partial g_{target}
}{
\partial g_{reference}
},
]

`indexationRate` repite lo mismo.

Usaría:

```haskell
newtype Indexation target reference =
  Indexation
    (Effect
      (GrowthRate target)
      (GrowthRate reference))
```

Por ejemplo:

```haskell
Indexation NominalWage PriceLevel
```

representa:

[
\frac{
\partial(\Delta W/W)
}{
\partial(\Delta P/P)
}.
]

---

# 7. Corregiría `NominalWage`

Aquí hay una cuestión dimensional importante.

Esto:

```haskell
NominalWage :: NominalVar(PriceIndex)
```

no es correcto.

El salario nominal **no es un índice de precios**.

Es algo como:

[
[W]
===

\frac{\text{moneda}}{\text{trabajo}}
]

por ejemplo:

[
\frac{\text{COP}}{\text{trabajador}}
]

o:

[
\frac{\text{COP}}{\text{hora de trabajo}}.
]

Entonces podrías tener:

```haskell
data NominalWage =
  NominalWage
    MonetaryValue
    LaborUnit
```

conceptualmente:

```text
NominalWage
    = MonetaryValue / LaborQuantity
```

Mientras:

```haskell
data PriceLevel =
  PriceLevel PriceIndexSpec
```

Y entonces:

[
\boxed{
\text{RealWage}
===============

\frac{\text{NominalWage}}
{\text{PriceLevel}}
}
]

Puede representarse:

```haskell
data RealWage =
  RealWage
    NominalWage
    PriceLevel
```

o mediante un tipo general:

```haskell
RatioValue NominalWage PriceLevel
```

si tu álgebra dimensional lo permite.

---

# 8. ¿Qué es `laborProductivity`?

También tenemos una definición natural que encaja exactamente con tu convención anterior:

[
\boxed{
\text{LaborProductivity}
========================

# \frac{1}{L/Y}

\frac{Y}{L}.
}
]

Yo no introduciría un símbolo auxiliar abstracto.

Tipo:

```haskell
data LaborProductivity =
  LaborProductivity
    Output
    LaborService
```

o:

```haskell
type LaborProductivity =
  Ratio Output LaborService
```

con representación económica:

[
\frac{VA}{L^s}
]

si estás trabajando con valor agregado y servicios laborales.

Entonces:

```haskell
GrowthRate LaborProductivity
```

es exactamente:

[
\frac{
\Delta\left(1/(L^s/VA)\right)
}{
1/(L^s/VA)
}.
]

Eso mantiene tu preferencia por conservar visible la estructura de cocientes.

---

# 9. `Expectation`

También cambiaría esto:

```haskell
Expectation (household :: Measure, realWage :: ??)
```

`Household` no es una `Measure`.

Es el **agente o medida probabilística** bajo la cual se evalúa la expectativa.

Puedes tener:

```haskell
data Agent
  = Household
  | Firm
  | Government
  | FinancialSector
```

y:

```haskell
data Expectation agent x =
  Expectation x
```

Por tanto:

```haskell
Expectation Household RealWage
Expectation Firm RealWage
```

representan:

[
\mathbb E^H[W/P],
\qquad
\mathbb E^F[W/P].
]

Si quieres preservar explícitamente tu interpretación probabilística:

```haskell
data Measure agent
```

y:

```haskell
data Expectation measure x
```

entonces:

```haskell
Expectation (Measure Household) RealWage
```

sería todavía más fiel matemáticamente.

---

# 10. El `Gap` salarial correcto

Tu primer término no tiene como perturbando simplemente:

```haskell
Expectation Household RealWage
```

sino:

\[
\mathbb E^H[W/P]-W/P.
\]

Por tanto define:

```haskell
type HouseholdRealWageExpectationGap =
  Gap RealWage
```

con constructor:

```haskell
householdRealWageExpectationGap
  :: Expectation Household RealWage
  -> RealWage
  -> HouseholdRealWageExpectationGap
```

que produce conceptualmente:

\[
\operatorname{Gap}
\left(
\mathbb E^H[W/P],
W/P
\right).
\]

Para firmas:

```haskell
type FirmRealWageExpectationGap =
  Gap RealWage
```

pero con orientación opuesta:

\[
\operatorname{Gap}
\left(
W/P,
\mathbb E^F[W/P]
\right).
\]

Esto muestra que quizás `Gap x` debería preservar **orientación**:

```haskell
data Gap x =
  Gap
    { positiveTerm :: x
    , negativeTerm :: x
    }
```

porque:

[
a-b
\neq b-a.
]

---

# 11. `ExpectationsConflict`

El conflicto final sí es:

\[

\mathbb E^H[W/P]
-
\mathbb E^F[W/P].

\]

Entonces:

```haskell
type RealWageExpectationsConflict =
  ExpectationsConflict
    Household
    Firm
    RealWage
```

y estructuralmente:

```haskell
newtype ExpectationsConflict agentA agentB x =
  ExpectationsConflict
    (Gap x)
```

con constructor:

```haskell
mkExpectationsConflict
  :: Expectation agentA x
  -> Expectation agentB x
  -> ExpectationsConflict agentA agentB x
```

# 12. `CommonGrowthRate`

```haskell
data CommonGrowthRate a b =
  CommonGrowthRate (GrowthRate a)
```

y un smart constructor:

```haskell
mkCommonGrowthRate
  :: GrowthRate a
  -> GrowthRate b
  -> Maybe (CommonGrowthRate a b)
```



```haskell
nominalWageGrowth
  :: GrowthRate NominalWage

nominalWageGrowth =
    ResponseMultiplier
      NominalWageGrowth
      HouseholdRealWageExpectationGap

      * householdRealWageExpectationGap

  + ResponseMultiplier
      NominalWageGrowth
      LaborProductivityGrowth

      * laborProductivityGrowth

  + Indexation
      NominalWage
      PriceLevel

      * inflationRate
```

Matemáticamente:

> This is the end goal test 
\[
\boxed{
\frac{\Delta W}{W}
=
\underbrace{
\frac{\partial(\Delta W/W)}{\partial\left(\mathbb E^H[W/P]-W/P\right)}}_{\text{ResponseMultiplier}}
\underbrace{\left(\mathbb E^H[W/P]-W/P\right)}_{\text{Gap RealWage}}
}
\]

\[
\boxed{
\qquad+
\underbrace{
\frac{
\partial(\Delta W/W)
}{
\partial\left[
\Delta(1/(L^s/VA))/(1/(L^s/VA))
\right]
}
}*{\texttt{ResponseMultiplier}}
\underbrace{
\frac{
\Delta(1/(L^s/VA))
}{
1/(L^s/VA)
}
}*{\texttt{GrowthRate LaborProductivity}}
}
\]

\[
\boxed{
\qquad+
\underbrace{
\frac{
\partial(\Delta W/W)
}{
\partial(\Delta P/P)
}
}*{\texttt{Indexation}}
\underbrace{
\frac{\Delta P}{P}
}*{\texttt{GrowthRate PriceLevel}}.
}
\]

```text


Gap(x)
│
└── Conflict(x)
    ├── ExpectationsConflict(agentA, agentB, x)
    ├── DistributionalConflict(x)
    └── BargainingConflict(x)


Effect(responder, perturband)
│
├── ResponseMultiplier(responder, perturband)
│
├── Elasticity(responder, perturband)
└── DistributionalEffect(responder, distributionVariable)
    └── NetDistributionalEffect


GrowthRate(x)
│
└── CommonGrowthRate(x, y)


Indexation(target, reference)
└── Effect(
      GrowthRate target,
      GrowthRate reference
    )
```
- `Gap` no sabe economía; `Conflict` sí. 
- `Effect` no sabe por qué ocurre la derivada; sus refinamientos sí.

> Eso permite reutilizar las estructuras algebraicas básicas en Kalecki, Kaldor, Minsky, fiscal, educación, etc., sin duplicar la semántica de cada módulo.


# CASO PRUEBA

- Nivel -> Nivel

El gobierno fijo un salario minimo de 20000 COP por hora

- Nivel -> Tasa

Prosa 

El gobierno incremento el salario nominal en 20 puntos porcentuales respecto al ano anterior

-> Si el ano anterior el salario nominal era de 10 unidades monetarias por 1 unidad de trabajo.
Este ano el salario nominal son 12 unidades monetarios por 1 unidad de trabajo


Scale 
// we need to define Scale 

Valuation = Nominal | Real PriceIndex

Bounds = Bounds {min :: Maybe , max :: Maybe }


LaborUnit = LaborUnit { scale :: Scale }
LaborBasis = Worker | LaborHour 
WorkerUnit = WorkerUnit { workerCountScale :: Scale }
LaborTimeUnit = LaborHourUnit{ laborScale :: Scale, timeUnit::TimeUnit}

MoneyUnit = MoneyUnit { currency :: Currency, unit:: Unit}
Currency = COP | USD 
COP = COP { unit: Billion | Million | Thousand , base = 50}

EconomicQuantity <valuation, unit> = EconomicQuantity { amount:: Number,valuation :: valuation,unit:: unit}

data CompoundUnit numerator denominator = Per numerator denominator | Times a b

NominalWage:: EconomicQuantity Nominal (CompoundUnit MoneyUnit LaborUnit )

- Tasa -> Tasa

Prosa: 

El gobierno incremento el salario nominal en 20 puntos basicos respecto al ano anterior

-> Si el ano anterior huho un incremento porcentual de 5 este ano fue de 5.20


