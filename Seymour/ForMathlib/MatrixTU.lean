import Mathlib.LinearAlgebra.Matrix.Determinant.TotallyUnimodular
import Seymour.ForMathlib.Basic
import Seymour.ForMathlib.FunctionDecompose


variable {X₁ X₂ Z : Type*}

lemma decomposeSum_card_eq [Fintype X₁] [DecidableEq X₁] [Fintype X₂] [DecidableEq X₂] [Fintype Z]
    (f : Z → X₁ ⊕ X₂) :
    Fintype.card { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } + Fintype.card { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } =
    Fintype.card Z := by
  rw [←Fintype.card_sum]
  exact Fintype.card_congr f.decomposeSum.symm

variable {R : Type*}

lemma Matrix.IsTotallyUnimodular.comp_rows [CommRing R] {A : Matrix X₁ X₂ R}
    (hA : A.IsTotallyUnimodular) (e : Z → X₁) :
    Matrix.IsTotallyUnimodular (A ∘ e) := by
  rw [Matrix.isTotallyUnimodular_iff] at hA ⊢
  intro k f g
  exact hA k (e ∘ f) g

lemma Matrix.IsTotallyUnimodular.comp_cols [CommRing R] {A : Matrix X₁ X₂ R}
    (hA : A.IsTotallyUnimodular) (e : Z → X₂) :
    Matrix.IsTotallyUnimodular (A · ∘ e) := by
  rw [Matrix.isTotallyUnimodular_iff] at hA ⊢
  intro k f g
  exact hA k f (e ∘ g)

variable {Y₁ Y₂ : Type*}

/-- `Matrix.fromBlocks_isTotallyUnimodular` preprocessing. -/
private lemma Matrix.fromBlocks_submatrix [Zero R] (A₁ : Matrix X₁ Y₁ R) (A₂ : Matrix X₂ Y₂ R)
    (f : Z → X₁ ⊕ X₂) (g : Z → Y₁ ⊕ Y₂) :
    (fromBlocks A₁ 0 0 A₂).submatrix f g =
    (fromBlocks
      (A₁.submatrix
        ((·.val.snd) : { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
        ((·.val.snd) : { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
      ) 0 0
      (A₂.submatrix
        ((·.val.snd) : { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
        ((·.val.snd) : { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
      )
    ).submatrix f.decomposeSum g.decomposeSum := by
  rw [
    f.eq_comp_decomposeSum,
    g.eq_comp_decomposeSum,
    ←Matrix.submatrix_submatrix]
  aesop

/-
In the comments bellow, we will use the following shorthands:

`Z` is the next indexing type (for both rows and cols of the big square submatrix), typically `Fin k`

`▫X₁` denotes `{ x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd }`
`▫X₂` denotes `{ x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd }`
`▫Y₁` denotes `{ y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd }`
`▫Y₂` denotes `{ y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd }`

`X'` is a specific subset of `▫X₂` converted to a type
`(▫X₂ \ X')` is its complement as a type, formally written as `{ x // x ∉ X' }` (where `x : ▫X₂` implicitly)

`I` is `Equiv.refl _`
` | ` denotes `Equiv.sumCongr`
`|S|` denotes `Fintype.card S` for any `{S : Type*} [Fintype S]`
-/
variable [LinearOrderedCommRing R] [Fintype Z] [DecidableEq Z]
  [Fintype X₁] [DecidableEq X₁] [Fintype Y₁] [DecidableEq Y₁]
  [Fintype X₂] [DecidableEq X₂] [Fintype Y₂] [DecidableEq Y₂]

/-- `Matrix.fromBlocks_isTotallyUnimodular` square case. -/
private lemma Matrix.fromBlocks_submatrix_det_in_set_range_singType_cast_of_isTotallyUnimodular_of_card_eq
    {A₁ : Matrix X₁ Y₁ R} (hA₁ : A₁.IsTotallyUnimodular)
    {A₂ : Matrix X₂ Y₂ R} (hA₂ : A₂.IsTotallyUnimodular)
    {f : Z → X₁ ⊕ X₂} {g : Z → Y₁ ⊕ Y₂}
    (hfg :
      Fintype.card { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } =
      Fintype.card { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } ∧
      Fintype.card { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } =
      Fintype.card { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd }) :
    ((fromBlocks A₁ 0 0 A₂).submatrix f g).det ∈
      Set.range SignType.cast := by
  rw [Matrix.isTotallyUnimodular_iff_fintype] at hA₁ hA₂
  rw [Matrix.fromBlocks_submatrix]
  let e₁ : { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } ≃ { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } :=
    Fintype.equivOfCardEq hfg.1
  let e₂ : { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } ≃ { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd } :=
    Fintype.equivOfCardEq hfg.2
/-
  ` f :  Z -> X₁ ⊕ X₂ `
  ` g :  Z -> Y₁ ⊕ Y₂ `
  are decomposed into
  ` f₁ :  ▫X₁ -> X₁ `
  ` f₂ :  ▫X₂ -> X₂ `
  ` g₁ :  ▫Y₁ -> Y₁ `
  ` g₂ :  ▫Y₂ -> Y₂ `

  Here we have ` |▫X₁| = |▫Y₁| ` and ` |▫X₂| = |▫Y₂| `

  ` ▫X₁ ⊕ ▫X₂ = Z = ▫Y₁ ⊕ ▫Y₂ `

  ` e₁ :  ▫X₁ ≃ ▫Y₁ `
  ` e₂ :  ▫X₂ ≃ ▫Y₂ `

  ` g₁ ∘ e₁ :  ▫X₁ -> Y₁ `
  ` g₂ ∘ e₂ :  ▫X₂ -> Y₂ `

  ` (g₁ ∘ e₁) | (g₂ ∘ e₂) :  Z -> Y₁ ⊕ Y₂ `   (note that `f` has the same type)
-/
  have hAfg :
    (fromBlocks
      (A₁.submatrix
        ((·.val.snd) : { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
        ((·.val.snd) : { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
      ) 0 0
      (A₂.submatrix
        ((·.val.snd) : { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
        ((·.val.snd) : { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
      )
    ).submatrix f.decomposeSum g.decomposeSum
    = -- make outer submatrix bijective
    (fromBlocks
      (A₁.submatrix (·.val.snd) ((·.val.snd) ∘ e₁)) 0 0
      (A₂.submatrix (·.val.snd) ((·.val.snd) ∘ e₂))
    ).submatrix f.decomposeSum (g.decomposeSum.trans (Equiv.sumCongr e₁.symm e₂.symm))
  · ext
    simp only [Function.decomposeSum, Equiv.coe_fn_mk, Equiv.coe_trans, Equiv.sumCongr_apply, Function.comp_apply,
      Matrix.submatrix, Matrix.of_apply]
    split <;> split <;> simp
  rw [hAfg,
  -- absolute value of determinant was preserved by previous mappings,
    in_set_range_singType_cast_iff_abs, Matrix.abs_det_submatrix_equiv_equiv,
  -- we now express it as a product of determinants of submatrices in blocks
    Matrix.det_fromBlocks_zero₁₂, ←in_set_range_singType_cast_iff_abs]
  -- determinants of submatrices in blocks are in `Set.range SignType.cast` by TUness of `A₁` and `A₂`
  apply in_set_range_singType_cast_mul_in_set_range_singType_cast
  · apply hA₁
  · apply hA₂

/-- `Matrix.fromBlocks_isTotallyUnimodular` non-square case. -/
private lemma Matrix.fromBlocks_submatrix_det_in_set_range_singType_cast_of_card_lt
    (A₁ : Matrix X₁ Y₁ R) (A₂ : Matrix X₂ Y₂ R) {f : Z → X₁ ⊕ X₂} {g : Z → Y₁ ⊕ Y₂}
    (hfg :
      Fintype.card { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } <
      Fintype.card { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd }) :
    ((fromBlocks A₁ 0 0 A₂).submatrix f g).det ∈
      Set.range SignType.cast := by
  -- we will show that the submatrix is singular
  convert zero_in_set_range_singType_cast
  rw [Matrix.fromBlocks_submatrix]
  -- we need a new indexing type [`▫X₁ ⊕ ` a part of `▫X₂`] of the same cardinality as `▫Y₁` for the "top half"
  -- then the bottom left blocks will be all `0`s, hence we can multiply the two determinants, and the top left block will
  -- have at least one row made of `0`s, hence its determinant is `0`
  have hZY₁ :
      Fintype.card { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } ≤
      Fintype.card { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } +
      Fintype.card { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd }
  · rw [decomposeSum_card_eq]
    apply Fintype.card_le_of_embedding
    use (·.val.fst)
    intro ⟨⟨_, u⟩, _⟩ ⟨⟨_, v⟩, _⟩ huv
    simp_rw [Subtype.mk.injEq] at huv ⊢
    simp_all only [Sum.inl.injEq]
  obtain ⟨X', hY₁, hX'⟩ := finset_of_cardinality_between hfg hZY₁
  have hY₂ : Fintype.card { y // y ∉ X' } = Fintype.card { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd }
  · suffices :
        Fintype.card { y // y ∉ X' } + Fintype.card ({ x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } ⊕ X') =
        Fintype.card { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } +
        Fintype.card { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd }
    · omega
    rw [Fintype.card_sum, add_comm, add_assoc, ←Fintype.card_sum, Fintype.card_congr (Equiv.sumCompl (· ∈ X')),
      decomposeSum_card_eq, decomposeSum_card_eq]
  let e₁ := Fintype.equivOfCardEq hY₁
  let e₂ := Fintype.equivOfCardEq hY₂
  let e₃ := (Equiv.sumAssoc { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } X' { x // x ∉ X' }).symm
  let e' := (Equiv.sumCompl (· ∈ X')).symm
/-
  ` f :  Z -> X₁ ⊕ X₂ `
  ` g :  Z -> Y₁ ⊕ Y₂ `
  are decomposed into
  ` f₁ :  ▫X₁ -> X₁ `
  ` f₂ :  ▫X₂ -> X₂ `
  ` g₁ :  ▫Y₁ -> Y₁ `
  ` g₂ :  ▫Y₂ -> Y₂ `

  ` ▫X₁ ⊕ ▫X₂ = Z = ▫Y₁ ⊕ ▫Y₂ `

  Here we have ` |▫X₁| < |▫Y₁| ` and so ` |▫X₂| > |▫Y₂| `

  We choose `X'` so that ` |▫X₁ ⊕ X'| = |▫Y₁| `(hY₁) and therefore ` |▫X₂ \ X'| = |▫Y₂| `(hY₂)

  ` e₁ :  ▫X₁ ⊕ X' ≃ ▫Y₁ `
  ` e₂ :  ▫X₂ \ X' ≃ ▫Y₂ `

  ` e₃ :  ▫X₁ ⊕ (X' ⊕ (▫X₂ \ X')) ≃ (▫X₁ ⊕ X') ⊕ (▫X₂ \ X') `

  ` e' :  ▫X₂ ≃ X' ⊕ (▫X₂ \ X') `

  ` I | e' :  ▫X₁ ⊕ ▫X₂ ≃ ▫X₁ ⊕ (X' ⊕ (▫X₂ \ X')) `

  ` e₃ ∘ (I | e') :  Z ≃ (▫X₁ ⊕ X') ⊕ (▫X₂ \ X') `
-/
  have hAfg :
    (fromBlocks
      (A₁.submatrix
        ((·.val.snd) : { x₁ : Z × X₁ // f x₁.fst = Sum.inl x₁.snd } → X₁)
        ((·.val.snd) : { y₁ : Z × Y₁ // g y₁.fst = Sum.inl y₁.snd } → Y₁)
      ) 0 0
      (A₂.submatrix
        ((·.val.snd) : { x₂ : Z × X₂ // f x₂.fst = Sum.inr x₂.snd } → X₂)
        ((·.val.snd) : { y₂ : Z × Y₂ // g y₂.fst = Sum.inr y₂.snd } → Y₂)
      )
    ).submatrix f.decomposeSum g.decomposeSum
    = -- make outer submatrix bijective
    (fromBlocks
      (fromRows (A₁.submatrix (·.val.snd) ((·.val.snd) ∘ e₁)) 0)
      (fromRows 0 (A₂.submatrix (·.val.val.snd) ((·.val.snd) ∘ e₂)))
      0
      (A₂.submatrix (·.val.val.snd) ((·.val.snd) ∘ e₂))
    ).submatrix
      ((f.decomposeSum.trans ((Equiv.refl _).sumCongr e')).trans e₃)
      (g.decomposeSum.trans (Equiv.sumCongr e₁.symm e₂.symm))
  · ext
    simp only [Function.decomposeSum, Equiv.coe_fn_mk, Equiv.coe_trans, Equiv.sumCongr_apply, Function.comp_apply,
      Matrix.submatrix, Matrix.of_apply, e₃, e']
    split
    · split <;> simp [Equiv.sumCompl, Equiv.sumAssoc, Matrix.fromBlocks, Matrix.fromRows]
    · split <;>
        simp only [Matrix.fromBlocks, Matrix.fromRows, Sum.elim_inl, Sum.elim_inr, Sum.map_inl, Sum.map_inr,
          Equiv.sumAssoc, Equiv.sumCompl, Equiv.coe_fn_symm_mk, Set.mem_range, Matrix.zero_apply] <;> split <;>
        simp
  rw [hAfg, ←abs_eq_zero, Matrix.abs_det_submatrix_equiv_equiv, abs_eq_zero]
  convert_to
    (fromRows (A₁.submatrix (·.val.snd) ((·.val.snd) ∘ e₁)) 0).det * (A₂.submatrix (·.val.val.snd) ((·.val.snd) ∘ e₂)).det
      = 0
  · convert -- none of `exact` `apply` `rw` `erw` `simp_rw` works with `Matrix.det_fromBlocks_zero₂₁` here
      Matrix.det_fromBlocks_zero₂₁
        (fromRows (A₁.submatrix (·.val.snd) ((·.val.snd) ∘ e₁)) 0)
        (fromRows 0 (A₂.submatrix (·.val.val.snd) ((·.val.snd) ∘ e₂)))
        (A₂.submatrix (·.val.val.snd) ((·.val.snd) ∘ e₂))
  convert zero_mul _
  exact Matrix.det_eq_zero_of_row_eq_zero (Sum.inr (Classical.choice hX')) (fun _ => rfl)

omit Z

/-- The block matrix that has two totally unimodular matrices along the diagonal and zeros elsewhere is totally unimodular. -/
lemma Matrix.fromBlocks_isTotallyUnimodular {A₁ : Matrix X₁ Y₁ R} {A₂ : Matrix X₂ Y₂ R}
    (hA₁ : A₁.IsTotallyUnimodular) (hA₂ : A₂.IsTotallyUnimodular) :
    (fromBlocks A₁ 0 0 A₂).IsTotallyUnimodular :=
  fun k f g _ _ =>
    if hxy :
        Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } =
        Fintype.card { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd } ∧
        Fintype.card { x₂ : Fin k × X₂ // f x₂.fst = Sum.inr x₂.snd } =
        Fintype.card { y₂ : Fin k × Y₂ // g y₂.fst = Sum.inr y₂.snd }
    then
      Matrix.fromBlocks_submatrix_det_in_set_range_singType_cast_of_isTotallyUnimodular_of_card_eq hA₁ hA₂ hxy
    else if hxy₁ :
        Fintype.card { x₁ : Fin k × X₁ // f x₁.fst = Sum.inl x₁.snd } <
        Fintype.card { y₁ : Fin k × Y₁ // g y₁.fst = Sum.inl y₁.snd }
    then
      Matrix.fromBlocks_submatrix_det_in_set_range_singType_cast_of_card_lt A₁ A₂ hxy₁
    else by
      rw [←Matrix.det_transpose, Matrix.transpose_submatrix, Matrix.fromBlocks_transpose]
      apply Matrix.fromBlocks_submatrix_det_in_set_range_singType_cast_of_card_lt
      have := decomposeSum_card_eq f
      have := decomposeSum_card_eq g
      omega
