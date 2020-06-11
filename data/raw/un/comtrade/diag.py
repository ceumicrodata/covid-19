with open("error_log.txt") as f:
    errors=f.readlines()

errors=list(set(errors))
print("All error logged: ",len(errors))

cerror=list(set([x.strip().split(",")[0] for x in errors]))
print("Error with countries: ", len(cerror)," and ",cerror)
