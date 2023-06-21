#!/bin/Rscript

# Quirky, but does the job.

# Computes expectation values for a composite
# system built from two quantum spins.
#
# Used with either with 1 or 5 arguments:
#	<operator> [wave-function (uu, ud, du, dd)]
#
# Each argument is parsed and evaluated, so you can
# use "tau_x %*% sigma_x" as an operator for example.
#
# If only an operator is provided (1 arg), its 4x4 matrix form
# is displayed as LaTeX on stdout.
#
# Otherwise, evaluates the expectation value for the operator
# for a system in a state described by the wave-function.

tmp <- "/tmp/R/lib"
.libPaths(tmp)
dir.create(tmp, recursive = TRUE, mode = "0755")

loadpkg <- function(p) {
	if (!require(p, character.only = TRUE)) {
		install.packages(p, repos='http://cran.us.r-project.org', lib=tmp)
		library(p, character.only = TRUE)
	}
}

# 2x2 identity and Pauli matrices
id2 = matrix(c(1,  0,  0,  1), 2, 2)
pz  = matrix(c(1,  0,  0, -1), 2, 2)
px  = matrix(c(0,  1,  1,  0), 2, 2)
py  = matrix(c(0, 1i, -1i, 0), 2, 2)

# Ugprade subsystem spin component operators to the composite system
sigma_z = kronecker(pz, id2)
tau_z   = kronecker(id2, pz)

sigma_x = kronecker(px, id2)
tau_x   = kronecker(id2, px)

sigma_y = kronecker(py, id2)
tau_y   = kronecker(id2, py)

# Expectation value computation
avg <- function(L, psi) {
	return((Conj(t(psi)) %*% L %*% psi)[1])
}

# Evaluate CLI arguments (e.g. "interpret" "tau_z %*% sigma_z"
# as the corresponding observable)
#
# Note that we need a list (lapply), as some of the arguments will be
# vectors already.
args <- lapply(
	commandArgs(trailingOnly = TRUE),
	function(x) { return(eval(parse(text=x))) }
)

# LaTeX export
loadpkg("xtable")

# See https://tales.mbivert.com/on-exporting-r-complex-matrix-latex/
xtable <- function(x, ...) {
	if (class(x[[1]]) == "complex") {
		z <- sapply(x, function(y) {
			if (y == 0)     return(as.character(0))
			if (Im(y) == 0) return(as.character(Re(y)))

			t <- ""
			if (Re(y) != 0) t <- as.character(Re(y))

			if (Im(y) == 1) {
				if (Re(y) == 0) t <- "i"
				else            t <- paste(t, "+i")
			} else if (Im(y) == -1)
				t <- paste(t, "-i")
			else {
				if (Re(y) == 0)     t <- paste(Im(y), "i")
				else if (Im(y) > 0) t <- paste(t, "+", Im(y), "i")
				else                t <- paste(t, Im(y), "i")
			}
			return(t)
		})
		dim(z) <- dim(x)
		xtable::xtable(z, ...)
	} else
		xtable::xtable(x, ...)
}

if (length(args) == 1) {
	x <- xtable(args[[1]], align=rep("",ncol(args[[1]])+1))

	# 1.00 -> 1, in our peculiar case
	digits(x) <- xdigits(x)
	print(x,
		floating = FALSE, tabular.environment = "pmatrix",
		hline.after=NULL, include.rownames=FALSE, include.colnames=FALSE
	)
	q()
} else if (length(args) != 5) stop("Incomplete wave function")

x <- avg(args[[1]], unlist(args[2:5]))

# avoids some 0+0i; refinable
if (x == 0) {cat(0, "\n")} else {cat(x, "\n")}
