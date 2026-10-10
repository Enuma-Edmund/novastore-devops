package com.novastore;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    public String name;
    public String category;
    public BigDecimal price;
    public String icon;
    public Integer stock;

    @Version
    public Long version;

    protected Product() {}
}
