% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TaskRegr_dti.R
\name{mlr_tasks_dti}
\alias{mlr_tasks_dti}
\title{Diffusion Tensor Imaging (DTI) Regression Task}
\format{
\link[R6:R6Class]{R6::R6Class} inheriting from \link[mlr3:TaskRegr]{mlr3::TaskRegr}.
}
\description{
This dataset contains two functional covariates and three scalar covariate. The goal is
to predict the PASAT score. \code{pasat} represents the PASAT score at each vist.
\code{subject_id} represents the subject ID. \code{cca} represents the fractional anisotropy tract profiles from the corpus
callosum. \code{sex} indicates subject's sex. \code{rcst} represents the fractional anisotropy tract profiles from the right
corticospinal tract. Rows containing NAs are removed.

This is a subset of the full dataset, which is contained in the package \code{refund}.
}
\section{Dictionary}{

This \link[mlr3:Task]{Task} can be instantiated via the \link[mlr3misc:Dictionary]{dictionary} \link[mlr3:mlr_tasks]{mlr_tasks}
or with the associated sugar function \link[mlr3:mlr_sugar]{tsk()}:

\if{html}{\out{<div class="sourceCode">}}\preformatted{mlr_tasks$get("dti")
tsk("dti")
}\if{html}{\out{</div>}}
}

\section{Meta Information}{

\itemize{
\item Task type: \dQuote{regr}
\item Dimensions: 340x4
\item Properties: \dQuote{groups}
\item Has Missings: \code{FALSE}
\item Target: \dQuote{pasat}
\item Features: \dQuote{cca}, \dQuote{rcst}, \dQuote{sex}
}
}

\references{
Goldsmith, Jeff, Bobb, Jennifer, Crainiceanu, M C, Caffo, Brian, Reich, Daniel (2011).
\dQuote{Penalized functional regression.}
\emph{Journal of Computational and Graphical Statistics}, \bold{20}(4), 830--851.

Brain dataset courtesy of Gordon Kindlmann at the Scientific Computing and Imaging Institute, University of Utah,
and Andrew Alexander, W. M. Keck Laboratory for Functional Brain Imaging and Behavior, University of
Wisconsin-Madison.
}
\seealso{
\itemize{
\item Chapter in the \href{https://mlr3book.mlr-org.com/}{mlr3book}:
\url{https://mlr3book.mlr-org.com/chapters/chapter2/data_and_basic_modeling.html}
\item Package \CRANpkg{mlr3data} for more toy tasks.
\item Package \CRANpkg{mlr3oml} for downloading tasks from \url{https://www.openml.org}.
\item Package \CRANpkg{mlr3viz} for some generic visualizations.
\item \link[mlr3misc:Dictionary]{Dictionary} of \link[mlr3:Task]{Tasks}: \link[mlr3:mlr_tasks]{mlr_tasks}
\item \code{as.data.table(mlr_tasks)} for a table of available \link[mlr3:Task]{Tasks} in the running session (depending on the loaded packages).
\item \CRANpkg{mlr3fselect} and \CRANpkg{mlr3filters} for feature selection and feature filtering.
\item Extension packages for additional task types:
\itemize{
\item Unsupervised clustering: \CRANpkg{mlr3cluster}
\item Probabilistic supervised regression and survival analysis: \url{https://mlr3proba.mlr-org.com/}.
}
}

Other Task: 
\code{\link{mlr_tasks_fuel}},
\code{\link{mlr_tasks_phoneme}}
}
\concept{Task}
