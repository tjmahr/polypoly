
# poly() as Q of a QR decomposition
mm <- model.matrix(~ 0 + x + I(x^2) + I(x ^ 3), data = list(x = 1:10))
mm

centered_mm <- apply(mm, 2, function(x) x - mean(x))
centered_mm

qr_version <- qr.Q(qr(centered_mm))
poly_version <- poly(1:10, degree = 3, simple = TRUE)

qr_version
poly_version

# They are not equal. This is at first unexpected.
all.equal(qr_version, poly_version, check.attributes = FALSE)

# But it's because of some negative signs
zapsmall(cor(qr_version, poly_version))

all.equal(qr_version[, 1], poly_version[, 1])

# Equal when we flip the sides of one of them
all.equal(qr_version[, 2], -poly_version[, 2])
all.equal(qr_version[, 3], -poly_version[, 3])


qr.Q(qr(mm))
qr.R(qr(mm))

qr.Q(qr(centered_mm))
qr.R(qr(centered_mm))
poly(1:10, degree = 3)






# Is it safe to rescale the matrix?
pm <- poly(1:30, degree = 3)
zapsmall(cor(pm))
polypoly::poly_plot(pm)

# I want degree 1 to span a unit change in x
span <- max(pm[, 1]) - min(pm[, 1])
scale <- 1 / span
unit_change <- pm * scale

zapsmall(cor(unit_change))
polypoly::poly_plot(unit_change)


# I want degree 1 to span a 10 unit change in x
scale <- 10 / span
ten_change <- pm * scale
polypoly::poly_plot(ten_change)
