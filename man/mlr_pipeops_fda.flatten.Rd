% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PipeOpFDAFlatten.R
\name{mlr_pipeops_fda.flatten}
\alias{mlr_pipeops_fda.flatten}
\alias{PipeOpFDAFlatten}
\title{Flattens Functional Columns}
\description{
Convert regular functional features (e.g. all individuals are observed at the same time-points)
to new columns, one for each input value to the function.
}
\section{Parameters}{

The parameters are the parameters inherited from \code{\link[mlr3pipelines:PipeOpTaskPreprocSimple]{PipeOpTaskPreprocSimple}}.
}

\section{Naming}{

The new names generally append a \verb{_1}, ...,  to the corresponding column name.
However this can lead to name clashes with existing columns.
This is solved as follows:
If a column was called \code{"x"} and the feature is \code{"mean"}, the corresponding new column will
be called \code{"x_mean"}. In case of duplicates, unique names are obtained using \code{make.unique()} and
a warning is given.
}

\examples{
task = tsk("fuel")
pop = po("fda.flatten")
task_flat = pop$train(list(task))
}
\section{Super classes}{
\code{\link[mlr3pipelines:PipeOp]{mlr3pipelines::PipeOp}} -> \code{\link[mlr3pipelines:PipeOpTaskPreproc]{mlr3pipelines::PipeOpTaskPreproc}} -> \code{\link[mlr3pipelines:PipeOpTaskPreprocSimple]{mlr3pipelines::PipeOpTaskPreprocSimple}} -> \code{PipeOpFDAFlatten}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-PipeOpFDAFlatten-new}{\code{PipeOpFDAFlatten$new()}}
\item \href{#method-PipeOpFDAFlatten-clone}{\code{PipeOpFDAFlatten$clone()}}
}
}
\if{html}{\out{
<details open><summary>Inherited methods</summary>
<ul>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="help"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-help'><code>mlr3pipelines::PipeOp$help()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="predict"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-predict'><code>mlr3pipelines::PipeOp$predict()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="print"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-print'><code>mlr3pipelines::PipeOp$print()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="train"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-train'><code>mlr3pipelines::PipeOp$train()</code></a></span></li>
</ul>
</details>
}}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-PipeOpFDAFlatten-new"></a>}}
\if{latex}{\out{\hypertarget{method-PipeOpFDAFlatten-new}{}}}
\subsection{Method \code{new()}}{
Initializes a new instance of this Class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{PipeOpFDAFlatten$new(id = "fda.flatten", param_vals = list())}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{id}}{(\code{character(1)})\cr
Identifier of resulting object, default \code{"fda.flatten"}.}

\item{\code{param_vals}}{(named \code{list()})\cr
List of hyperparameter settings, overwriting the hyperparameter settings that would
otherwise be set during construction. Default \code{list()}.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-PipeOpFDAFlatten-clone"></a>}}
\if{latex}{\out{\hypertarget{method-PipeOpFDAFlatten-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{PipeOpFDAFlatten$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
