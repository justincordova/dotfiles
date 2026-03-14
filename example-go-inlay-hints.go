package main

import "fmt"

type User struct {
	Name string
	Age  int
}

func greet(name string) string {
	return "Hello, " + name
}

func main() {
	name := "Alice"
	count := 42
	active := true
	fmt.Println("Name:", name, "Active:", active)

	users := []User{
		{Name: "Bob", Age: 30},
		{Name: "Charlie", Age: 25},
	}

	for i, user := range users {
		fmt.Println(greet(user.Name))
		fmt.Printf("User %d: %s, age %d\n", i, user.Name, user.Age)
	}

	result := calculate(count, 5)
	fmt.Println("Result:", result)
}

func calculate(a, b int) int {
	return a + b
}
