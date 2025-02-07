import Mathlib.Data.Matroid.Map
import Seymour.Matroid.Operations.MatrixSums.Sum1
import Seymour.Matroid.Operations.MatrixSums.Sum2
import Seymour.Matroid.Operations.MatrixSums.Sum3

/-!
This file states the Seymour decomposition theorem. Proving `hardSeymour` is the ultimate goal of this project.
THIS IS THE MAIN FILE OF THE OLD VERSION (everything in terms of explicit matrices).
-/

variable {α : Type} [DecidableEq α]

/-- TODO define graphics matroids. -/
def StandardRepresentation.IsGraphic (M : StandardRepresentation α) : Prop :=
  sorry

/-- TODO define cographics matroids. -/
def StandardRepresentation.IsCographic (M : StandardRepresentation α) : Prop :=
  sorry

/-- TODO define R10. -/
def matroidR10 : StandardRepresentation α :=
  sorry -- inside we have some `Fin 10 ↪ α` whose image is `E`

/-- Given matroid can be constructed from graphic matroids & cographics matroids & R10 using 1-sums & 2-sums & 3-sums. -/
inductive StandardRepresentation.IsGood : StandardRepresentation α → Prop
-- leaf constructors
| graphic {M : StandardRepresentation α} (hM : M.IsGraphic) : M.IsGood
| cographic {M : StandardRepresentation α} (hM : M.IsCographic) : M.IsGood
| theR10 {M : StandardRepresentation α} {e : α ≃ Fin 10} (hM : M.toMatroid.mapEquiv e = matroidR10.toMatroid) : M.IsGood
-- fork constructors
| is1sum {M M₁ M₂ : StandardRepresentation α} (hM : M.Is1sumOf M₁ M₂) : M.IsGood
| is2sum {M M₁ M₂ : StandardRepresentation α} (hM : M.Is2sumOf M₁ M₂) : M.IsGood
| is3sum {M M₁ M₂ : StandardRepresentation α} (hM : M.Is3sumOf M₁ M₂) : M.IsGood

/-- THE HOLY GRAIL. -/
theorem oldSeymour {M : StandardRepresentation α} (hM : M.IsRegular) : M.IsGood := by
  sorry
