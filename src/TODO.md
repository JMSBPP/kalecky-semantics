> Delivered 2026-08-16 per docs/superpowers/specs/2026-08-16-state-vectors-and-intensity-design.md — see src/Kalecky/Types/{Groups,Panel,Stocks} and src/Kalecky/Operators/Intensity.hs.



2. `StateVector` is a type BUT there are relavant INSTANCES that must be packed on a package with name relevant (e.g once defined `Groups`). There is a type `Groups -> StateVector`

Given \(G = F | K | LI | L | ML \)That does this for population:

\[
	\begin{aligned}
	N = 
		\begin{bmatrix}
			N_K \\
			N_F \\
			N_{LI} \\
			N_{L} \\
			N_{ML} \\
			\sum N_i
		\end{bmatrix}
	\end{aligned}
\]

Note that this StateVector does not store raw numbers. it store a type that encapsulates a Stock AND

Stock offers as type a [LOCATION][TIME] panel with api service to query the panel AND it has a reference to the total such that each Stock instance hknows is correct with reepsstec to the total, Meaniing haivng a stale N_i is not possible since updating N_i is after uodating N and checks the sum on the dimentiosn cheks out. This is a polymorphic type, since stock can also represnet a single data poitn  stock value that guarantees and guards operations not possible to be run on it to be done on it

From `StateVector` the following instances apply:

\[
	\begin{aligned}
		FK = 
		\begin{bmatrix}
			K \\
			L \\
			E \\
			A
		\end{bmatrix} = 
		\begin{bmatrix}
			K_F \oplus K_K \oplus K_{MC} \\
			L_I \oplus L_F \oplus L_{ML} \\
			E_G \oplus E_{pr}
		\end{bmatrix}
	\end{aligned}
\]

> Another thing to note is the presence of othe groups AND the fact that Stock types do not store single panels BUT there are functions that can qeury different measures on the STcok varianvbe alone. The actual type defintion is to be discussed

Note the following operator:

`Intensity:: StateVector` -> `StateVector`


\[
	\begin{aligned}
		\begin{bmatrix}
			\frac{K}{N} \\
			\frac{E}{N} \\
			\cdots
		\end{bmatrix}
	\end{aligned}
\]


From here, a few inmediate type chekcs follow:

- Note that the inverse fraction is not allowed, thus the Stock type carries some type arg to flag the Intensity operator for the order of the operation. The inners of that vector note that are not stocks  but intensity ratios which hva eits own name and its name is under discussion targeting which one has more economic meaning


