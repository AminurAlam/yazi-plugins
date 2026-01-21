#set text(1.35em)
#set par(justify: false)
#set page(margin: 25pt)

== central tendenceis

/ MEAN ($mu$):

$
          "direct": & (sum f_i x_i)/n \
         "assumed": & a + sum(f_i d_i)/n "      " d_i = x_i - a \
  "step deviation": & a + sum(f_i u_i)/n h "    " u_i = (x_i - a)/h
$

/ MEDIAN:
$ l + h / f (n / 2 - c f) $

/ MODE:
$ l + frac(f_1 - f_0, 2 f_1 - f_0 - f_2) h $

/ STANDARD DEVIATION:
$ sum (x_i - mu)^2/ n $

== probablity
$ P (A inter B) = P (A \| B) P (B) = P (B \| A) P (A) $

== mean
$
    "AM" & = (x_1 + x_2 + . . . + x_n) / n \
    "GM" & = zws^n sqrt(x_1 med x_2 med . . . med x_n) \
    "HM" & = frac(n, (1 \/ x_1) + (2 \/ x_2) + . . . + (1 \/ x_n)) \
  "GM"^2 & = A M times H M
$

== integration
$
  integral x^n d x & = (x^(n+1))/(n+1) \
  integral e^n d x & = e^n \
  integral a^x d x & = (a^x)/(log a ) \
  integral 1/x d x & = log x \
  integral u v d x & = u integral v d x - integral ((d)/(d x)u integral v d x )d x \
$

= DISCRETE
$
                   "mean" (mu) & = E(x) \
                               & = sum_(i=1)^n f_i x_i \
          "variance" (sigma^2) & = "Var"(x) \
                               & = E(x^2) - mu^2 \
                               & = sum_(i=1)^n f_i x_i^2 - (sum_(i=1)^n f_i x_i )^2 \
  "standard deviation" (sigma) & = sqrt("Var"(x))
$

== binomial (bernauli)

- n is small
- two outcomes: success (p) or fail (q)

$
                           "pmf" & = f(X=x) = attach(C, tl: n)_x p^x q^(n-x) \
                                 \
                     "mean" (mu) & = n p \
            "variance" (sigma^2) & = n p q \
  "standard" "deviation" (sigma) & = sqrt(n p q)
$

== poisson

- n is large
- p is very small


$
  "pmf" & = f(X=x, lambda = n p) = (e^(-lambda) dot lambda^x)/(x!) \
  \
  "mean" (mu) & = lambda = n p \
  "variance" (sigma^2) & = lambda = n p \
  "standard deviation" (sigma) & = sqrt(lambda) = sqrt(n p)
$


= CONTINUOUS
== uniform

$
                         "pdf" & = f(alpha \< x \< beta) = (1)/(beta - alpha) \
                               \
                   "mean" (mu) & = E(x) = (alpha + beta)/(2) \
          "variance" (sigma^2) & = "Var"(x) = ((beta - alpha)^2)/(12) \
  "standard deviation" (sigma) & = (beta - alpha)/(sqrt(12))
$


== exponential

$
                           "pdf" & = f(0 <= x < infinity) = lambda e^(-lambda x) \
                           "pdf" & = f(0 <= x < a) = 1 - e^(-lambda a) \
                                 \
                     "mean" (mu) & = E(x) = (1)/(lambda) \
            "variance" (sigma^2) & = "Var"(x) = (1)/(lambda^2) \
  "standard" "deviation" (sigma) & = sqrt(lambda) = sqrt(n p)
$


== normal

$
                         "pdf" & = f(-infinity < x < infinity, mu, sigma) \
                               & = 1/(sigma sqrt(2 pi)) e^(-1/2((x-mu)/(sigma))^2) \
                               \
                   "mean" (mu) & = E(x) \
                               & = integral_(-infinity)^(infinity) x f(x) d x \
          "variance" (sigma^2) & = "Var"(x) \
                               & = integral_(-infinity)^(infinity)(x-mu)^2 f(x) d x \
  "standard deviation" (sigma) & = sqrt(lambda) \
                               & = sqrt(n p) \
$


== log normal

== standard normal

$
  "pdf" & = f((x-mu_1)/(sigma) < z < (x-mu_2)/(sigma)) \
        & = f(z < (x-mu_2)/(sigma)) - f(z < (x-mu_1)/(sigma)) \
     mu & = n plus.minus m
$


== gamma

$
                 "pdf" & = f(X=x, lambda, r) \
                       & = (lambda^r x^(r-1) e^(-lambda x))/(Gamma r) \
                       \
               Gamma r & = integral_0^infinity x^(r-1)e^(-x)d x "       " 0 < x,r \
                       \
           "mean" (mu) & = E(x) = (r)/(lambda) \
  "variance" (sigma^2) & = "Var"(x) = (r)/(lambda^2) \
$


= JOINT DISTRIBUTION
$ P (a < x < b , c < y < d) = integral_a^b integral_c^d f (x , y) d x $

= SKEWNESS
$ ("mean" - "mode")/"std_dev" $

== Karl Pearson’s measure of skewness
$ (3("mean" - "median"))/"std_dev" $

== Bowley’s measure of skewness
$ (Q_3 - 2 "median" + Q_1)/(Q_3 - Q_1) $
$Q_1$: find median with median class as $N slash 4$ \
$Q_2$: find median with median class as $N slash 2$ \
$Q_2$: find median with median class as $3 N slash 4$

== Moment’s measure of skewness
$
     mu_r & = 1 / n sum f_i (x_i - dash(x))^r \
     mu_r & = h^r / n sum f_i med x_i^r "    (for assumed mean)" \
   beta_1 & = mu_3^2 / mu_2^3 \
  gamma_1 & = plus.minus sqrt(beta_1) = mu_3 / sigma^3 = alpha_3
$

== kurtosis
$
   beta_2 & = mu_4 / mu_2^2 \
  gamma_2 & = beta_2 - 3
$

$
  cases(
    beta_2 = 3 "  meso kurtic",
    beta_2 < 3 "  platy kurtic",
    beta_2 > 3 "  lepto kurti",
  )
$

= CORRELATION

== Karl Pearson’s coefficient of correlation
$
  r & = frac(n sum x y - sum x sum y, sqrt(n sum x^2 - (sum x)^2) sqrt(n sum y^2 - (sum y)^2)) \
  r & = frac(C o v (x , y), sigma_x med sigma_y)
$

== Spearmann’s rank correlation
$ rho = 1 - (6 sum d^2 )/(n(n^2 - 1)) d_i = R x_i - R y_i $

== concurrent deviations
$ r c = sqrt((2C-N)/(N)) "        C: +ve " delta_x delta_y $
