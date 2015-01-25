/* random number generator for American Roulette */

data sample;
upperbound=38;
n=0; 						  /* variable to keep track of the increment */
do i = 1 to 100;
   u = uniform(-1); 		  /* generate uniform random variable */
   k = ceil(upperbound*u )-1; /* generate a random variable with u as a seed */
   if k=0 then n=(n+1);       /* n is number of times Lorena actually wins */
   payout = n*350;			  /* calculating the total payoff */
   xy = 1000-(n*10);
   output;
end;
   ExpectedNetPayout = payout-xy; /* Expected Net Payout after 100 counts of 10 dollar bets */
   output;
run;