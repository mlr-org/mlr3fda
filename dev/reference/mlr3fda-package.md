# mlr3fda: Extending 'mlr3' to Functional Data Analysis

Extends the 'mlr3' ecosystem to functional analysis by adding support
for irregular and regular functional data as defined in the 'tf'
package. The package provides 'PipeOps' for preprocessing functional
columns and for extracting scalar features, thereby allowing standard
machine learning algorithms to be applied afterwards. Available
operations include simple functional features such as the mean or
maximum, smoothing, interpolation, flattening, and functional 'PCA'.

## Data types

To extend mlr3 to functional data, two data types from the tf package
are added:

- `tfd_irreg` - Irregular functional data, i.e. the functions are
  observed for potentially different inputs for each observation.

- `tfd_reg` - Regular functional data, i.e. the functions are observed
  for the same input for each individual.

Lang M, Binder M, Richter J, Schratz P, Pfisterer F, Coors S, Au Q,
Casalicchio G, Kotthoff L, Bischl B (2019). “mlr3: A modern
object-oriented machine learning framework in R.” *Journal of Open
Source Software*.
[doi:10.21105/joss.01903](https://doi.org/10.21105/joss.01903) ,
<https://joss.theoj.org/papers/10.21105/joss.01903>.

## See also

Useful links:

- <https://mlr3fda.mlr-org.com>

- <https://github.com/mlr-org/mlr3fda>

- Report bugs at <https://github.com/mlr-org/mlr3fda/issues>

## Author

**Maintainer**: Sebastian Fischer <sebf.fischer@gmail.com>
([ORCID](https://orcid.org/0000-0002-9609-3197))

Authors:

- Maximilian Mücke <muecke.maximilian@gmail.com>
  ([ORCID](https://orcid.org/0009-0000-9432-9795))

Other contributors:

- Fabian Scheipl <fabian.scheipl@googlemail.com>
  ([ORCID](https://orcid.org/0000-0001-8172-3603)) \[contributor\]

- Bernd Bischl <bernd_bischl@gmx.net>
  ([ORCID](https://orcid.org/0000-0001-6002-6980)) \[contributor\]
