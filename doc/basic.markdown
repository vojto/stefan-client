# STEFAN: Seamless Teaching of dEaF children using AnimatioNs

Assignment: Text reader with built-in dictionary based on graphical illustrations and explanations of meanings of words and phrases

Stefan is a web-based tool for helping hearing-impaired children with reading text.

## Parsing text

Before all else, the string is split into phrases. A phrase can look like this:

![img1](https://github.com/vojto/stefan-client/raw/master/doc/images/Slide1_Part1.png)

The first step is to parse text and find keywords that should be pictured. To do this, the algorithm first tokenizes the string.

Now there is a list of keywords that are definitely not picturable. These are simply discarded:

![img1](https://github.com/vojto/stefan-client/raw/master/doc/images/Slide1_Part2.png)

The tokens that are left are grouped together resulting into meaningful expressions.

![img1](https://github.com/vojto/stefan-client/raw/master/doc/images/Slide1_Part3.png) 

These expressions are now first looked up in the built-in dictionary. If there is not result, a search against Google Images service is done. The result is that every expression is pictured:

![img1](https://github.com/vojto/stefan-client/raw/master/doc/images/Slide1_Part4.png)

## Built-in dictionary

