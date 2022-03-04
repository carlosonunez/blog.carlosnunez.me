---
title: "Render Golang templates with a timeout"
date: "2022-03-04 11:27:30"
slug: "render-golang-templates-with-a-timeout"
image: "/images/render-golang-templates-with-a-timeout/header.jpeg"
keywords:
  - software development
  - golang
---

## Situation

You're writing a Go program that renders arbitrary
[Go templates](link) that users can write. Since they are arbitrary, you want to prevent
users from accidentally DDoSing your program by using long-running template functions.
Something like this:

```go
import (
  "os"
  "template"
)
// Perhaps this is exposed through an interface that a
// third-party API implements, for example.
func LongRunningFunction(s string) {
  time.Sleep(100000000) // This takes forever

  return s
}

func main() {
  tmpl := `Hello, {{ .LongRunningFunction . }}!`
  t, err := template.New("my-template").Parse(tmpl)
  if err != nil {
    panic(err)
  }
  t.Execute(os.Stdout, "Carlos")
}
```

When `t.Execute` runs, it will wait **ten million seconds** before displaying
"Hello, Carlos" to your terminal.

Obviously, this is not ideal.

## Solution That You Want To Exist But Doesn't

_Perhaps I could use a `context.Context` to have Go send a `SIGINT` upon
exceeding a deadline_, you're probably thinking.

Unfortunately, [the Go authors disagree with
you](https://github.com/golang/go/issues/31107).

## Actual Solution

Fortunately, `goroutines` make implmenting timeouts insanely easy. Let's
explore:

```go
import (
  "fmt"
  "os"
  "template"
  "time"
)
// Perhaps this is exposed through an interface that a
// third-party API implements, for example.
func LongRunningFunction(s string) {
  time.Sleep(100000000) // This takes forever

  return s
}

func main() {
  timeoutSeconds := 5
  res := make(chan bool)
  go func() {
    tmpl := `Hello, {{ .LongRunningFunction . }}!`
    t, err := template.New("my-template").Parse(tmpl)
    if err != nil {
      panic(err)
    }
    t.Execute(os.Stdout, "Carlos")
    res <- true
  }
  select {
  case ok := <-res {
    return
  }
  case <-time.After(time.Duration(timeoutSeconds) * time.Second) {
    panic("timeout exceeded")
  }
}
```

`goroutines` allow you to create functions that execute asynchronously and
communicate through _channels_. You can think of _channels_ like pipes; you
send data into them, and data is consumed from them elsewhere.

You can learn more about the relationship between `goroutine`s and
channels
[here](https://scribe.rip/trendyol-tech/concurrency-and-channels-in-go-bbc4dea75286).

Furthermore, the `select` statement is kind-of like a `switch`-`case` for
channels. It awaits on multiple channels and selects the channel that sends data
first.  You can learn more about the select statement
[here](https://gobyexample.com/select).

Putting it all together, instead of rendering our template directly
from `main`, we render it asynchronously inside of a `goroutine` and have it
send a flag to the `res` channel when its work is complete. At the same time, we
open another channel with `time.After` that sends a time after the provided
duration; five seconds in our case. Because we are using a `select` statement to
wait on both and our `goroutine` won't finish for **SIXTEEN WEEKS**,
the latter case wins and we `panic`.

Happy programming!
