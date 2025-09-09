run: main
	./main
main: main.c libtrimmed.so
	gcc -o main main.c -L. -ltrimmed -Wl,-rpath,.
libtrimmed.so: src/TrimmableCAPIsViaSumTypes.jl
	JULIAC=$$(julia -e 'print(normpath(joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "juliac", "juliac.jl")))' 2>/dev/null || echo "") ; \
	julia --project=. "$$JULIAC" --trim=unsafe-warn --compile-ccallable --experimental --output-lib libtrimmed loadlib.jl
