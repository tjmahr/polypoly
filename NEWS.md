# polypoly 0.0.3

  - Fix rlang warning. (\#1, thanks @mvuorre)
  
  - `poly_add_columns()` gains an `na_values` argument for how to handle missing
    values. Default is `"error"` to raise an error. Other options include
    `"warn"` to ignore the missing values but raise a warning and `"allow"` to
    silently accept the missing values. (\#2)

# polypoly 0.0.2

  - Initial CRAN release.
