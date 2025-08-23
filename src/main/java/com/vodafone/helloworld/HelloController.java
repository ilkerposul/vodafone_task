package com.vodafone.helloworld;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "Hello World. - İlker Poşul";
    }

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
