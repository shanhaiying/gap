\\ calculates the exponentsvectors of the fractional ideals
\\ generated by elms corresponding to the prime ideals 
\\ arrissing in the factorization

nf = nfinit(f);

\\ factorize all ideals generated by the elements of a and collect all
\\ primideals which occur
primId=eval(Set(concat(vector(#elms-1,i,idealfactor(nf,Polrev(elms[i]))[,1]))));

\\ write for every element in a the exponentfactor corresponding to the
\\ ideals in primId in a row
\\ so we will have a matrix
mat = matrix(#elms-1,#primId,i,j,idealval(nf,Polrev(elms[i]),primId[j]));
print("[ ");
{
  for(i=1,#mat,
    print(mat[i,],",");
  );
  print("];");
}