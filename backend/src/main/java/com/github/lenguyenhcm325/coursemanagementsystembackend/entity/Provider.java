package com.github.lenguyenhcm325.coursemanagementsystembackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "Providers")
public class Provider {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private int id;

  @Column(name = "name")
  private String name;

  @OneToMany(mappedBy = "provider")
  private List<Course> courses;

  @Override
  public String toString() {
    return "Provider{" + "id=" + id + ", name='" + name + '\'' + ", courses=" + courses + '}';
  }
}
