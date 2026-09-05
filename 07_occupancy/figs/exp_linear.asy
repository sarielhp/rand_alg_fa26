import  graph;


size(8cm,6cm,IgnoreAspect);
//size(400,400,IgnoreAspect);
unitsize( 2cm );
settings.outformat="pdf";



//This means ticks at an interval of 2.0, between -8 and 8 for both
//the x and y axes.

real f(real x) 
{ 
  return exp(x); 
} 
real g(real x) 
{ 
  return 1.0+x; 
} 


//pen thin=linewidth(0.5*linewidth());
Label f; 
f.p=fontsize(6); 


pen thin=linewidth(0.5*linewidth());
draw(graph(f,-10,2.3), blue+1, "$e^x$");
draw(graph(g,-2,4), red+1,  "$1+x$");


xlimits(-10,4);
ylimits(-1,10);
xaxis("$x$",//-10,4,//Ticks(f, 2.0),
      BottomTop,
      Ticks(Step=2.0,extend=true,begin=false,end=false,
                               darkgreen+0.0125)); 
yaxis( "$y$", LeftRight, Ticks(Step=1.0,extend=true,begin=false,end=false,
                               darkgreen+0.0125 ) ); 

attach(legend(2),(point(S).x,truepoint(S).y),10S,UnFill);
