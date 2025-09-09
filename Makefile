run: main
	./main
main: main.c libtrimmed.so
	gcc -o main main.c -L. -ltrimmed -Wl,-rpath,.
libtrimmed.so: src/TrimmableCAPIsViaSumTypes.jl
	julia --project=. ~/.julia/juliaup/julia-1.12.0-rc2+0.x64.linux.gnu/share/julia/juliac/juliac.jl --trim=unsafe-warn --compile-ccallable --experimental --output-lib libtrimmed loadlib.jl
