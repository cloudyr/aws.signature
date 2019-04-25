test_that("NULL is blank", {
  expect_true(is_blank(NULL))
})

test_that("empty string is blank", {
  expect_true(is_blank(""))
})

test_that("Non-empty string is not blank", {
  expect_false(is_blank("foo"))
})
