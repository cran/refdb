

# test <- read.csv("tests/testthat/data_baetidae_bold.csv")

test_that("Test checking taxonomic typo", {
  test <- read.csv("data_baetidae_bold.csv")
  test <- refdb_set_fields_BOLD(test)

  test$species_name[10] <- "Baetis aplinus"
  test$order_name[5] <- "Ehemeroptera"

  res <- refdb_check_tax_typo(test, tol = 1)
  expect_equal(sum(sapply(res, length)), 2L)

  res <- refdb_check_tax_typo(test, tol = 2)
  expect_equal(sum(sapply(res, length)), 4L)

})


test_that("Test checking taxonomic conflicts", {
  test <- read.csv("data_baetidae_bold.csv")
  test <- refdb_set_fields_BOLD(test)

  test$order_name[5] <- "Ehemeroptera"

  res <- refdb_check_tax_conflict(test)
  # 8L corresponds to conflicts detected above family_name (included)
  expect_equal(sum(sapply(res, nrow)), 8L)

})


test_that("Test checking sequence conflicts", {
  test <- read.csv("data_baetidae_bold.csv")
  test <- refdb_set_fields_BOLD(test)

  test$nucleotides[29] <- test$nucleotides[10]

  res <- refdb_check_seq_conflict(test)

  expect_equal(ncol(res), 3L)
  expect_equal(nrow(res), 2L)
})


# test_that("Test reports", {
#   test <- read.csv("data_baetidae_bold.csv")
#   test_file <- tempfile()
#   test <- refdb_set_fields_BOLD(test)
#   refdb_report(test, test_file, view = FALSE)
#   refdb_report(test, view = FALSE)
# })



test_that("Test refdb_check_seq_homogeneity fails with non aligned sequences", {
  test <- read.csv("data_baetidae_bold.csv")
  test <- refdb_set_fields_BOLD(test)

  expect_error(refdb_check_seq_homogeneity(test, levels = c(species = 0.05)),
               "Sequences must be aligned")
})

# test <- read.csv("tests/testthat/data_tocheck_homogeneity.csv")
test_that("Test refdb_check_seq_homogeneity", {
  test <- read.csv("data_tocheck_homogeneity.csv")
  test <- refdb_set_fields_BOLD(test)

  r1 <- refdb_check_seq_homogeneity(test, levels = c(species = 0.05))
  r2 <- refdb_check_seq_homogeneity(test, levels = c(genus = 0.1, species = 0.05))
  r3 <- refdb_check_seq_homogeneity(test, levels = c(species = 0.05, genus = 0.1))

  expect_equal(nrow(r1), 7L)
  expect_equal(nrow(r2), 10L)
  expect_equal(r2, r3)
})
